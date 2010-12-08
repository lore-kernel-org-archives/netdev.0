From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: eliminate pgv_to_page on some arches
Date: Wed, 08 Dec 2010 10:44:03 -0800 (PST)
Message-ID: <20101208.104403.102554903.davem@davemloft.net>
References: <1291731976-15793-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jpirko@redhat.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33159
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753896Ab0LHSng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:43:36 -0500
In-Reply-To: <1291731976-15793-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue,  7 Dec 2010 22:26:16 +0800

> Some arches don't need flush_dcache_page(), and don't implement it, so
> we can eliminate pgv_to_page() calls on those arches.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
