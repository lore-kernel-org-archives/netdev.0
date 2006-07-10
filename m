From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] IB/mthca: comment fix
Date: Mon, 10 Jul 2006 13:18:09 +0200
Message-ID: <1152530289.4874.19.camel@laptopd505.fenrus.org>
References: <20060710111412.GD24705@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>,
	Zach Brown <zach.brown@oracle.com>, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44978 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751385AbWGJLS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 07:18:27 -0400
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20060710111412.GD24705@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-10 at 14:14 +0300, Michael S. Tsirkin wrote:
> Hi Andrew,
> Here's a cosmetic patch for IB/mthca. Pls drop it into -mm and on.
> 
> ---
> 
> comment in mthca_qp.c makes it seem lockdep is the only reason WQ locks should
> be initialized separately, but as Zach Brown and Roland pointed out, there are
> other reasons, e.g. that mthca_wq_init is called from modify qp as well.

ehh.. shouldn't the comment say that instead then? that's one tricky
thing and might as well have that documented in the code!

