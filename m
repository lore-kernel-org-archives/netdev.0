From: Ryan Phillips <ryan@trolocsis.com>
Subject: IPv4 Netmask with Multiple IPv6 Link Local Addresses Problem
Date: Wed, 18 Feb 2009 15:17:34 -0600
Message-ID: <46a47f950902181317v13680c17x77c0778fef99d036@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:29599 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754289AbZBRVRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 16:17:35 -0500
Received: by rv-out-0506.google.com with SMTP id g37so86278rvb.1
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 13:17:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All...

I'm working on an embedded product using Linux 2.6.25.5 for PowerPC.
In a dual stack environment with eth0 assigned a Link Local and IPv4
address. I can assign a second link-local IPv6 address to the
interface, but the IPv4 netmask gets changes to 0.0.0.0. Is this
expected behavior for IPv6 or is this a bug?

Thanks,
Ryan Phillips
