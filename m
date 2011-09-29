From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Network problem with bridge and virtualbox
Date: Thu, 29 Sep 2011 23:56:55 +0200
Message-ID: <4E84E9A7.4080008@gmail.com>
References: <20110929124941.GA16567@electro-mechanical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: William Thompson <wt@electro-mechanical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52071 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab1I2V4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 17:56:45 -0400
Received: by wwf22 with SMTP id 22so1727559wwf.1
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 14:56:44 -0700 (PDT)
In-Reply-To: <20110929124941.GA16567@electro-mechanical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/09/2011 14:49, William Thompson a =E9crit :
> Please keep me in the CC as I am not subscribed.
>
> I'm using a 64-bit kernel 3.0.0 and virtualbox 4.1.2.
>
> My problem is that I cannot ping the host from a virtual machine.
>
> My bridge is configured as follows:
> # brctl addbr br0
> # brctl setfd br0 0
> # brctl stp br0 off
> # ifconfig br0 10.2.3.1 netmask 255.255.255.0
>
> In the virtual machine, it is set to use br0 as it's interface (bridg=
e mode)
> and it's IP is 10.2.3.10.

Why do you use bridge with VirtualBox?

VirtualBox provide several network modes, which remove the need for bri=
dge on the host.

One of Bridged Network mode (using eth0), Internal Networking mode or H=
ost-only Networking mode may=20
suit your need well, without having to use a bridge.

	Nicolas.
