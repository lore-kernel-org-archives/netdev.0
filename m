From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: Cleanup command queue scatterlist usage
Date: Fri, 01 May 2009 21:26:50 -0700 (PDT)
Message-ID: <20090501.212650.211196891.davem@davemloft.net>
References: <20090501.153301.42015656.davem@davemloft.net>
	<20090502032646.7927.99584.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, sfr@canb.auug.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: alex.williamson@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46095
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746AbZEBE0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 00:26:55 -0400
In-Reply-To: <20090502032646.7927.99584.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 01 May 2009 21:27:56 -0600

> We were avoiding calling sg_init* on scatterlists passed
> into virtnet_send_command to prevent extraneous end markers.
> This caused build warnings for uninitialized variables.
> Cleanup the code to create proper scatterlists.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Applied.
