From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: r8169
Date: Fri, 11 Dec 2009 10:17:49 +0100
Message-ID: <4B220E3D.5030502@lastsummer.de>
References: <20091210205821.GX6965@slinky.marshes.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Marsh <mushypea@dominion.net.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:38932 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbZLKJRw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Dec 2009 04:17:52 -0500
In-Reply-To: <20091210205821.GX6965@slinky.marshes.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ian,

> After many hours of frustration trying to solve this, I am hoping you guys can
> shed some light and help me out.
>
> I have a PC with an Asus P5B i965 motherboard, which has an on-board gigabit
> ethernet port.  According to dmesg this is a "RTL8168b/8111b", lspci reports a
> "Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
> Express Gigabit Ethernet controller [10ec:8168] (rev 01)".
>
> This PC is a media centre PC, currently using Xubuntu Hardy (8.04.1), with
> stock kernel image, 2.6.24-19-generic.  This uses version 2.2LK of the r8169
> driver (according to modinfo, srcversion: 449281D8F257330CF6D0E38), which
> works perfectly.
>   

At work we're also using ubuntu which comes with the r8169 driver,
and had to deal with network dropouts while trying to benchmark
heavy loads. This is what the support of our boxes told us:

>Please use 8168 instead of 8169. Please see the notice about this
>important point in May..
>
>The situation you observed should be a misjudgment by the Linux Kernel.
>Driver 8168 is recommended by Realtek. Please use this revision.


No more problems since then. Hope that helps!


Franco
