From: David Brownell <david-b@pacbell.net>
Subject: Re: [2.6 patch] let USB_USBNET always select MII
Date: Thu, 1 Nov 2007 16:52:39 -0700
Message-ID: <200711011652.39601.david-b@pacbell.net>
References: <200711012024.57412.toralf.foerster@gmx.de> <20071101222524.GB7227@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.sbc.mail.sp1.yahoo.com ([69.147.64.94]:25462 "HELO
	smtp121.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754958AbXKAXwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 19:52:41 -0400
In-Reply-To: <20071101222524.GB7227@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 November 2007, Adrian Bunk wrote:
> All this USB_USBNET_MII trickery is simply not worth it considering h=
ow=20
> few code it saves.

Depends on what systems you're talking about.  Forcing unused
code into the kernel is not free, especially if that's made into
a design policy and applied repeatedly to many subsystems.


> As a side effect, this also fixes the following compile error reporte=
d=20
> by Toralf F=F6rster:

Why not just fix the thing which changed and broke the build?

Or if reverse dependencies can't be made to work sanely, then
have those Ethernet-adapter minidrivers depend on NET_ETHERNET
and then select MII.  (To make the relationships be simple
enough that current Kconfig can handle them.)

I have a fair number of usbnet devices.  Not one of them needs
MII or NET_ETHERNET.

- Dave

