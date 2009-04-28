From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: Cleanup command queue scatterlist usage
Date: Tue, 28 Apr 2009 02:30:52 -0700 (PDT)
Message-ID: <20090428.023052.98414161.davem@davemloft.net>
References: <20090426.233014.216353908.davem@davemloft.net>
	<20090427154925.4771.63651.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, sfr@canb.auug.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: alex.williamson@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56846
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754170AbZD1Ja7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 05:30:59 -0400
In-Reply-To: <20090427154925.4771.63651.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 27 Apr 2009 09:50:03 -0600

> We were avoiding calling sg_init* on scatterlists passed
> into virtnet_send_command to prevent extraneous end markers.
> This caused build warnings for uninitialized variables.
> Cleanup the code to create proper scatterlists.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Looks good to me, what say you Rusty?
