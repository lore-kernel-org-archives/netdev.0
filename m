From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: 2.6.23-mm1 tg3 wake-on-lan oddity...
Date: Tue, 27 Nov 2007 08:04:28 -0800
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABB51@nt-irva-0751.brcm.ad.broadcom.com>
References: <24400.1196156118@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4269 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754667AbXK0QEk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 11:04:40 -0500
Content-class: urn:content-classes:message
In-Reply-To: <24400.1196156118@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valdis.Kletnieks@vt.edu wrote:

> (a) the Dell factory default is WOL disabled and (b) 
> if it wasn't
> the default, I'd have *set* it to disabled, and (c) I even 
> went back and
> rebooted and checked the BIOS setting - disabled. Nonetheless:
> 
> # ethtool eth0 | grep Wake
>         Supports Wake-on: g
>         Wake-on: g
> 
> Is this expected behavior?
> 

The new tg3 is supposed to follow the WoL setting in the
NVRAM, so this is not expected.  We'll have to look into
this.

