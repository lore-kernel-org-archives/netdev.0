From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: 802.1Q support?
Date: Mon, 12 Jan 2009 22:46:57 +0200
Message-ID: <20090112204657.GP5688@mea-ext.zmailer.org>
References: <200901121148.26905.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:58298 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753624AbZALUrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 15:47:03 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S3542886AbZALUq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 22:46:57 +0200
Content-Disposition: inline
In-Reply-To: <200901121148.26905.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 11:48:26AM -0500, Robin Getz wrote:
> I'm trying to understand the "standard" way to control a switch which
> supports VLAN.

"Standard" way would be to telnet to it, and issue IOS commands..
(or any other variant of things.)

> Pick any one of:
>  
> Infineon XWAY ADM6999 (eight-port 10/100 plus one MII) 
> http://www.infineon.com/cms/en/product/channel.html?channel=ff80808112ab681d0112ab68ce8d0043
>  
> Micrel MS8993M (2 port 10/100 plus one MII)
> http://www.micrel.com/_PDF/Ethernet/ks8993m_pb.pdf 
>  
> Broadcom BCM5325E (five port 10/100 plus one MII)
> http://www.broadcom.com/collateral/pb/5325E-PB00-R.pdf
>  
> Realtek (five port 10/100 plus one MII) 
> http://www1.futureelectronics.com/doc/REALTEK%20SEMICONDUCTOR/Realtek%20Semiconductor%20RTL8306SD-GR.pdf
>  
> They all have multiple MAC/PHYs which are exposed to the wire, and a
> single MII interface - which normally connects directly to a SOC's MII/MAC.
> 
> I would have thought that there would be separate drivers for these in the 
> phylib, but I didn't find anything that looked like it would work.
> (or expose the right interface (all the vendor specific VLAN registers) so
> I can program them properly from userspace)...
> 
> It is possible to hack up the specific EMAC driver to do everything, but
> that doesn't seem like the right way to do it...

In Linux Kernel there is VLAN support - but that happens well inside the 
network stack, not at network card drivers.

Doing something similar to what  vconfig tool does is definitely an option.
Doing it with vconfig ?   Probably not.  Layering problem, you see.

> Any pointers appreciated.
> Thanks.

/Matti Aarnio
