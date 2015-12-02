From: Teco Boot <teco@inf-net.nl>
Subject: Re: [PATCH net 1/1] via-rhine: fix VLAN receive handling regression.
Date: Wed, 2 Dec 2015 10:55:40 +0100
Message-ID: <CABAB3EF-4A65-4534-AE27-D9B069CAB0F7@inf-net.nl>
References: <20130807003431.GD16410@order.stressinduktion.org> <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl>
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: andrej@ota.si, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35450 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308AbbLBJzo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 04:55:44 -0500
Received: by wmuu63 with SMTP id u63so207357100wmu.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 01:55:42 -0800 (PST)
In-Reply-To: <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I faced this problem on 4.2.6, Debian Jessie, on PC Engines Alix6. 
I applied the patch. It solved the problem.

Queue up for -stable?

Teco

> 
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Thu, 15 Oct 2015 00:14:37 +0200
> 
> > From: Andrej Ota <andrej@ota.si>
> > 
> > Because eth_type_trans() consumes ethernet header worth of bytes, a call
> > to read TCI from end of packet using rhine_rx_vlan_tag() no longer works
> > as it's reading from an invalid offset.
> > 
> > Tested to be working on PCEngines Alix board.
> > 
> > Fixes: 810f19bcb862 ("via-rhine: add consistent memory barrier in vlan receive code.")
> > Signed-off-by: Andrej Ota <andrej@ota.si>
> > Acked-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> Applied.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
