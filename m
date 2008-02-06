From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/5] forcedeth: phy status fix
Date: Wed, 06 Feb 2008 06:43:45 -0500
Message-ID: <47A99D71.8090707@pobox.com>
References: <47A7720C.90405@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40802 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759928AbYBFLnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 06:43:47 -0500
In-Reply-To: <47A7720C.90405@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> The driver needs to ack only the phy status bits that it is currently 
> handling and preserve the other bits for the other handlers. For 
> example, when reading/writing from the phy, it should not clear the link 
> change interrupt bit. This will cause a missing link change interrupt.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied


