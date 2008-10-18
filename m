From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.27 seems to break something with DSL (fwd)
Date: Sat, 18 Oct 2008 23:11:05 +0200
Message-ID: <48FA50E9.4080105@gmail.com>
References: <Pine.LNX.4.64.0810171611100.2939@olon.olon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: olon@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:7915 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbYJRVLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 17:11:09 -0400
Received: by ug-out-1314.google.com with SMTP id k3so371756ugf.37
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2008 14:11:07 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810171611100.2939@olon.olon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olon wrote, On 10/17/2008 10:11 PM:

> 
> Hi there,
> 
> I can confirm this issue.
> I'm using a westell dsl modem, and going from 2.6.26.5 to .27.  I found that I 
> couldn't connect to most websites either.
> This modem is in passthrough mode and not nat.

Could you try this?:
echo 0 > /proc/sys/net/ipv4/tcp_sack

It looks like it helped in a similar problem here:
http://bugzilla.kernel.org/show_bug.cgi?id=11721

Jarek P.

