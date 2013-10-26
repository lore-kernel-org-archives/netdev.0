From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 1/4] net: mvmdio: make orion_mdio_wait_ready
 consistent
Date: Sat, 26 Oct 2013 01:44:01 -0400 (EDT)
Message-ID: <20131026.014401.2297094945752640834.davem@davemloft.net>
References: <cover.1382199042.git.leigh@solinno.co.uk>
	<cover.1382637156.git.leigh@solinno.co.uk>
	<4955b6b331459b7b9c54350b8f0b254065d013c3.1382637156.git.leigh@solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	sebastian.hesselbarth@gmail.com
To: leigh@solinno.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620Ab3JZFoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 01:44:03 -0400
In-Reply-To: <4955b6b331459b7b9c54350b8f0b254065d013c3.1382637156.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leigh Brown <leigh@solinno.co.uk>
Date: Thu, 24 Oct 2013 19:09:31 +0100

> +	        else
> +			if (timedout)
>  				break;
>  

Please make this:

		else if (timedout)
			break;
