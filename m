From: Phil Oester <kernel@linuxace.com>
Subject: Re: The bonding driver should notify userspace of MAC address change
Date: Fri, 15 Apr 2011 12:12:49 -0700
Message-ID: <20110415191249.GA6879@linuxace.com>
References: <20110415184407.550abd88@pomiocik.lan>
 <4DA89114.9040900@gmail.com>
 <10227.1302893590@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>,
	=?us-ascii?B?PT9VVEYtOD9CP1RXbGphR0hGZ2lCSHc3Tnlibms9Pz0=?=
	<mgorny@gentoo.org>, netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:60487 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127Ab1DOTMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 15:12:53 -0400
Received: by pvg12 with SMTP id 12so1212738pvg.19
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 12:12:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <10227.1302893590@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 11:53:10AM -0700, Jay Vosburgh wrote:
> >A bonding device should not report link up to userspace until at least one slave is present and up.
> >
> >And possibly, a bonding device should report link down if all slaves are down or all slave were removed.
> >
> >Jay, Andy, does this sounds sensible to you?
> 
> 	I was just reading their bug and doing an experiment; I don't
> see that bonding reports carrier up until there's at least one slave
> (even if it's configured up), e.g.,
> 

This was only recently fixed - see e826eafa65c6f1f7c8db5a237556cebac57ebcc5
(bonding: Call netif_carrier_off after register_netdevice). Perhaps the
reporter is not using a recent kernel?

Phil 
