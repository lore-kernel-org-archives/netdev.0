From: Andrew Lutomirski <luto@mit.edu>
Subject: Source address selection vs. policy routing?
Date: Fri, 11 Jun 2010 06:41:50 -0400
Message-ID: <AANLkTik7NTl3VfJ1Bj84crVZPLQCHrX79WSddzqP2nHM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:64149 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab0FKKmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 06:42:11 -0400
Received: by pwi1 with SMTP id 1so372629pwi.19
        for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 03:42:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The docs seem rather vague
(http://linux-ip.net/html/routing-saddr-selection.html) and I'm about
to set up a system with two different internet connections, so I'll
ask here:

If I use policy routing (ip rule) based on the src selector and a
local application calls connect without first calling bind, how is the
source address selected?  (Just reading the docs naively gives a
circular answer: the routing table is chosen based on source address
and then the source address is influenced by the src field on the
chosen route.)

Similarly, how does masquerade choose its source address?

I took a look at the code, but all the fast paths, slow paths, and
flow structures are a bit confusing to the uninitiated.

Thanks,
Andy
