From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Fw: Build failure on linux-next master branch
Date: Mon, 24 Aug 2009 16:38:35 -0700
Message-ID: <1251157115.2950.85.camel@localhost.localdomain>
References: <20090825093707.13bf8c49.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:32990 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbZHXXjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 19:39:16 -0400
In-Reply-To: <20090825093707.13bf8c49.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

> [Let try a few folks who might know]
> 
> Begin forwarded message:
> 
> Date: Mon, 24 Aug 2009 12:00:24 -0400 (EDT)
> From: Steven Rostedt <rostedt@goodmis.org>
> To: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
> Subject: Build failure on linux-next master branch
> 
> 
> 
> With latest next master branch I got this failure in my build system.
> 
>   Building modules, stage 2.
> Kernel: arch/x86/boot/bzImage is ready  (#1801)
>   MODPOST 96 modules
> ERROR: "crc16" [net/bluetooth/l2cap.ko] undefined!
> make[1]: *** [__modpost] Error 1

just pushed a fix from Randy to bluetooth-next-2.6 tree. The
CONFIG_L2CAP was missing a select CRC16.

Regards

Marcel


