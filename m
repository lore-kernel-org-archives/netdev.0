From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Reproducible corruption with SG offloading
Date: Wed, 13 Jan 2010 21:06:27 +0100
Message-ID: <4B4E27C3.90003@gmail.com>
References: <4B4B181B.3020208@rabbit.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: Peter Rabbitson <rabbit+list@rabbit.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:34455 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754901Ab0AMUGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 15:06:32 -0500
Received: by fxm25 with SMTP id 25so584888fxm.21
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2010 12:06:31 -0800 (PST)
In-Reply-To: <4B4B181B.3020208@rabbit.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Rabbitson wrote, On 01/11/2010 01:22 PM:

> I have the following card:
> 
> 02:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)

...

> 	Kernel driver in use: tg3
> 
> When confronted with very specific repeatable data streams the card eventually
> starts setting garbage down the wire. If I do ethtool -k <ifname> sg off the
> problem disappears. Let me know if ou are interested in tracking this down,
> (whether software or hardware) otherwise I'll throw the card away and go with
> something else.
> 
> Please CC me as I am not subscribed to netdev@
> 
> This is my minimal test case with relevant data:

Interested or not, it would be useful to save more data on this, e.g. into
bugzilla report (plus some link here); especially the kernel version, these
tcpdumps as row files, ifconfigs, and as much as possible according to the
linux-2.6/REPORTING_BUGS.

Thanks,
Jarek P.
