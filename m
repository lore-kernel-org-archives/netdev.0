From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC/PATCH] network configs: disconnect network options from drivers
Date: Thu, 31 Mar 2005 22:30:10 +0200
Message-ID: <20050331203010.GA8034@mars.ravnborg.org>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net> <20050331185226.GA8146@mars.ravnborg.org> <424C5745.7020501@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ioe-lkml@axxeo.de, matthew@wil.cx,
	lkml <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
	hadi@cyberus.ca, cfriesen@nortel.com, tgraf@suug.ch
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261761AbVCaU3n@vger.kernel.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <424C5745.7020501@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2005 at 12:02:13PM -0800, Randy.Dunlap wrote:
> 
> Other than "sounds good," are there some comments on:
> 
> a.  leaving IrDA and Bluetooth subsystem (with drivers) where they
>     are, which is under "Network options and protocols"
> 	(I really don't want to split their drivers away from their
> 	subsystem, just to put them under Network driver support.)

Agreed. All IrDA / Bluetooth stuff belongs together.
Leave them where they are for now.

> 
> b.  leaving SLIP, PPP, and PLIP where they are under Network driver
>     support, even though they say that they are "protocols" ?
SLIP and PLIP is no that common. PPP is more common for cable-modem/ADSL
I suppose. But still it would make sense to create an Misc protocols
menu, like we have a misc filesystems menu.

	Sam
