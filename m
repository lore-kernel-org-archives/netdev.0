From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Strange TCP dump between a Linux and a Samsung phone
Date: Tue, 11 Nov 2008 17:05:25 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811111701260.3930@wrl-59.cs.helsinki.fi>
References: <4919910E.6080700@route66.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: ROUTE 66 - Catalin BOIE <cboie@route66.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39752 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755821AbYKKPF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 10:05:28 -0500
In-Reply-To: <4919910E.6080700@route66.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Nov 2008, ROUTE 66 - Catalin BOIE wrote:

> I have captured a strange dump between a Linux kernel
> 2.6.25.6-55.fc9.x86_64 and a Samsung device.

Please upgrade or prove that the tcp fixes that were in the later kernel 
(.7 iirc or 2.6.26) got applied into that -55 part.

> I looked at it and it seems that the Linux stack does not send any
> retransmissions to Samsung device.
> But, I want a competent look from you.
> 
> The connection is done over a 3G connection.
> The capture was done on a router between the two endpoints.
> c.66.com is the Linux machine, the other IP is the Samsung device.

...snip...

> As you may see, the Samsung device keeps sending an ACK for 1261841 and
> after some time closes the connection.
> Why the Linux stack does no retransmissions?

Looks like a know bug in frto which got fixed.

If upgrade is not an option, you can experiment by playing with tcp_frto 
sysctl (with 0 you should not encounter that bug).

-- 
 i.
