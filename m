From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH 1/3] Freescale QE UCC gigabit ethernet driver
Date: Fri, 7 Jul 2006 16:59:35 +0800
Message-ID: <4879B0C6C249214CBE7AB04453F84E4DF278@zch01exm20.fsl.freescale.net>
References: <FA983307-6A01-4FCB-A15A-ACC0E7B068A9@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Andrew Morton" <akpm@osdl.org>, <jgarzik@pobox.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:5355 "EHLO
	de01egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1750934AbWGGI5Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 04:57:16 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id k67AESNt027437
	for <netdev@vger.kernel.org>; Fri, 7 Jul 2006 04:14:28 -0600 (MDT)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id k678vDj7013227
	for <netdev@vger.kernel.org>; Fri, 7 Jul 2006 03:57:14 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <FA983307-6A01-4FCB-A15A-ACC0E7B068A9@kernel.crashing.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Kumar Gala [mailto:galak@kernel.crashing.org]
> Sent: Thursday, July 06, 2006 9:45 PM
> To: Li Yang-r58472
> Cc: Andrew Morton; jgarzik@pobox.com; netdev@vger.kernel.org;
> linuxppc-dev@ozlabs.org
> Subject: Re: [PATCH 1/3] Freescale QE UCC gigabit ethernet driver
> 
> Nack.  Here are some high level things that should be addressed:
> * There is a ton of debug code that should probably be stripped out,
> such as dump_regs, etc..

The reason I left these debug code in is that, QE is very flexible.
User probably needs to fine tune parameters for their own application.
It will be good to give them some clue doing that.  It's fine to remove
them, if you do think they are too verbose.
> * The phy support should use the phylib instead

I'll do this when I do get some time. ;)
> * convert from being a platform_device to of_device

I'm not up against moving to use of_device.  But why are we putting
extra effort in closing the door to backward compatibility with ppc
arch, and doesn't provide any new feature. ;)
> 
> - kumar
> 
