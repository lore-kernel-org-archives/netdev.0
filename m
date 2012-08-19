From: Andrew Worsley <amworsley@gmail.com>
Subject: Re: network packet corruption in v3.6.0-rc1 (and also in v3.5)
Date: Mon, 20 Aug 2012 06:20:52 +1000
Message-ID: <CA+Y=x3nFziC+=RhEz7aQofSy15gX=nKqFfQ2DEF0FwXTGmv7zQ@mail.gmail.com>
References: <CA+Y=x3=jSrEaYdnaAF75p0utQq02MhoSh4SkshRVSc7JjjVPOw@mail.gmail.com>
	<1345374134.5158.103.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62212 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864Ab2HSUUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 16:20:54 -0400
Received: by eaac11 with SMTP id c11so1809397eaa.19
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 13:20:52 -0700 (PDT)
In-Reply-To: <1345374134.5158.103.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> OK, this seems to be related to r8712u, still in staging tree.
>
> At first glance, its using a buggy skb_clone(), or kind of a 'reuse skb'
> trick I have no time to investigate.
>
> I suspect that some memory area are overwritten by this driver, and this
> was not noticed with older kernels. With new kernels, its triggering a
> WARN_ON() in tcp stack.
>
> Any chance you can try to reproduce the bug with another adapter ?

Unfortunately I don't have another USB dongle. I could try to get the built in

Broadcom Corporation BCM4331 802.11a/b/g/n (rev 02)
Subsystem: Apple Inc. Device 00ef

but I need to dig out the proprietary firmware - which will take some
time as I am not familiar with the procedure.

The weird thing about this USB dongle is that I brought it because it
was claimed to be supported under Linux

idVendor           0x0b05 ASUSTek Computer, Inc.
idProduct          0x1786 USB-N10 802.11n Network Adapter [Realtek RTL8188SU]

RealTek driver web site -  -
http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=48&PFid=48&Level=5&Conn=4&DownTypeID=3&GetDown=false&Downloads=true#RTL8188SU

which claims support "Linux Kernel 2.6.18~2.6.38 and Kernel 3.0.2"
but requires I try compiling the driver from source

Andrew
