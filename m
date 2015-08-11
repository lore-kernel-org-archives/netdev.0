From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fs_enet: explicitly remove I flag on TX partial
 frames
Date: Tue, 11 Aug 2015 12:05:44 -0700 (PDT)
Message-ID: <20150811.120544.493350093968384502.davem@davemloft.net>
References: <20150811101101.116E41A2414@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150811101101.116E41A2414@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Tue, 11 Aug 2015 12:11:00 +0200 (CEST)

> We are not interested in interrupts for partially transmitted frames,
> we have to clear BD_ENET_TX_INTR explicitly otherwise it may remain
> from a previously used descriptor.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Applied.
