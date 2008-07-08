From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan tag by hand
Date: Tue, 8 Jul 2008 21:33:51 +0200
Message-ID: <20080708193351.GE14330@xi.wantstofly.org>
References: <20080707205646.GB12997@xi.wantstofly.org> <4872841E.1030609@trash.net> <20080707210701.GD12997@xi.wantstofly.org> <48728784.2030202@trash.net> <487394CC.7050107@trash.net> <20080708185226.GD14330@xi.wantstofly.org> <4873B6E1.9010702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:60484 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbYGHTdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 15:33:53 -0400
Content-Disposition: inline
In-Reply-To: <4873B6E1.9010702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2008 at 08:50:09PM +0200, Patrick McHardy wrote:

> commit 9381fc4a49cb8b75d5ff38e4f5d14d7e135adc4c
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Tue Jul 8 19:56:17 2008 +0200
> 
>     vlan: avoid header copying and linearisation where possible

That gives me:

- 2.6.26-rc9 + [1] + [2] + this patch: ~75 sec, 13.6 MiB/s

So it's almost back to the non-VLAN case.


[1] "vlan 01/07: fix network_header/mac_header adjustments",
    http://marc.info/?l=linux-netdev&m=121543468509250&w=2

[2] "mv643xx_eth: enable hardware TX checksumming with vlan tags",
    http://marc.info/?l=linux-netdev&m=121546423330743&w=2
