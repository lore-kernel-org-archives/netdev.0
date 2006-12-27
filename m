From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 7/8] NetXen: Fix for PPC machines.
Date: Wed, 27 Dec 2006 07:58:54 +0000
Message-ID: <20061227075854.GA32567@infradead.org>
References: <200612181353.kBIDrx7D012229@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43650 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932957AbWL0H64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 02:58:56 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
Content-Disposition: inline
In-Reply-To: <200612181353.kBIDrx7D012229@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 18, 2006 at 05:53:59AM -0800, Amit S. Kale wrote:
> Signed-off-by: Amit S. Kale <amitkale@netxen.com> 
>  
>  netxen_nic.h      |    2 +-
>  netxen_nic_init.c |   12 ++++++------
>  netxen_nic_main.c |    4 ++--
>  3 files changed, 9 insertions(+), 9 deletions(-)

Please use __le* types for all hardware data structures and use sparse
to verify all your endianess handling is correct.

