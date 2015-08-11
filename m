From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fs_enet: mask interrupts for TX partial frames.
Date: Tue, 11 Aug 2015 12:05:49 -0700 (PDT)
Message-ID: <20150811.120549.725041722027995104.davem@davemloft.net>
References: <20150811101103.045721A2414@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150811101103.045721A2414@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Tue, 11 Aug 2015 12:11:03 +0200 (CEST)

> We are not interested in interrupts for partially transmitted frames.
> Unlike SCC and FCC, the FEC doesn't handle the I bit in buffer
> descriptors, instead it defines two interrupt bits, TXB and TXF.
> 
> We have to mask TXB in order to only get interrupts once the
> frame is fully transmitted.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Applied.
