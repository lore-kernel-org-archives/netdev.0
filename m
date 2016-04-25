From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] sh_eth: use EDMR_SRST_GETHER in sh_eth_check_reset()
Date: Mon, 25 Apr 2016 10:31:15 +1000
Message-ID: <20160425003115.GD30009@verge.net.au>
References: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
 <10299839.69pLJTKjhc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33333 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbcDYAbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 20:31:17 -0400
Content-Disposition: inline
In-Reply-To: <10299839.69pLJTKjhc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 24, 2016 at 11:45:23PM +0300, Sergei Shtylyov wrote:
> sh_eth_check_reset() uses a bare number where EDMR_SRST_GETHER would fit,
> i.e. the receive/trasmit software reset bits that comprise EDMR_SRST_GETHER
> read as 1  while the corresponding reset is in progress and thus, when both
> are 0, the reset is complete.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>
