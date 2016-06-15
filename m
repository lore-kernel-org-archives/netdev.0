From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCHv2 net-next] net: igb: Only dma sync
 frame	length
Date: Wed, 15 Jun 2016 01:40:35 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F1BC2E@ORSMSX101.amr.corp.intel.com>
References: <1464987805-17754-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Andrew Lunn <andrew@lunn.ch>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41115 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159AbcFOBki convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 21:40:38 -0400
In-Reply-To: <1464987805-17754-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Andrew Lunn
> Sent: Friday, June 3, 2016 2:03 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; David Miller
> <davem@davemloft.net>
> Cc: netdev <netdev@vger.kernel.org>; intel-wired-lan@lists.osuosl.org;
> Andrew Lunn <andrew@lunn.ch>
> Subject: [Intel-wired-lan] [PATCHv2 net-next] net: igb: Only dma sync frame
> length
> 
> On some platforms, syncing a buffer for DMA is expensive. Rather than
> sync the whole 2K receive buffer, only synchronise the length of the
> frame, which will typically be the MTU, or a much smaller TCP ACK.
> 
> For an IMX6Q, this gives around 6% increased TCP receive performance,
> which is cache operations bound and reduces CPU load for TCP transmit.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> v2:
> Christmas tree the local variables
> Pass size into igb_add_rx_frag() rather than repeating the endiness swap.
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
