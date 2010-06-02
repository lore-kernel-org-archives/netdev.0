From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: tcp_hybla: Fix integer overflow in slow start
 increment
Date: Wed, 02 Jun 2010 07:16:28 -0700 (PDT)
Message-ID: <20100602.071628.233878946.davem@davemloft.net>
References: <1275480124-24383-1-git-send-email-root@danielinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	linux-kernel@vger.kernel.org
To: root@danielinux.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59356
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751778Ab0FBOQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:16:18 -0400
In-Reply-To: <1275480124-24383-1-git-send-email-root@danielinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Lacamera <root@danielinux.net>
Date: Wed,  2 Jun 2010 14:02:04 +0200

> From: root <root@kitchen.(none)>

Please do not include incomplete authorship tags in your patch postings
like this, I used the more complete one from your email headers.

> For large values of rtt, 2^rho operation may overflow u32. Clamp down the increment to 2^16.
> Signed-off-by: Daniele Lacamera <root@danielinux.net>

Applied, thanks.
