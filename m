From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH] Experimental new bonding driver mode=batman
Date: Tue, 19 May 2015 03:58:19 -0400
Message-ID: <555AED1B.8050503@cumulusnetworks.com>
References: <555AD3A7.7050202@netscape.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick Simmons <linuxrocks123@netscape.net>,
	netdev@vger.kernel.org,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:36286 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbbESH6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 03:58:21 -0400
Received: by qget53 with SMTP id t53so3186689qge.3
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 00:58:20 -0700 (PDT)
In-Reply-To: <555AD3A7.7050202@netscape.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/15 2:09 AM, Patrick Simmons wrote:
> Hello,
>
> I've written a new mode for the kernel bonding driver.  It's similar to
> the round-robin mode, but it keeps statistics on TCP resends so as to
> favor slave devices with more bandwidth when choosing where to send
> packets.  I've tested it on two laptops using WiFi/Ethernet and it seems
> to work okay, but it should be considered experimental.
>
> Still, it should be safe to apply this patch as it doesn't do anything
> unless you specify "mode=batman" on the driver command line.
>
> Signed-off-by: Patrick Simmons <linuxrocks123@netscape.net>
>

It is usually a good idea to add the bonding maintainers directly, have 
added them. See <kernel>/MAINTAINERS for list.
