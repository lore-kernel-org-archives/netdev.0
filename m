From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] dst_entry structure use,lastuse and refcnt abstraction
Date: Thu, 23 Jun 2005 20:36:47 -0700 (PDT)
Message-ID: <20050623.203647.88475017.davem@davemloft.net>
References: <Pine.LNX.4.62.0506231953260.28244@graphe.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	shai@scalex86.org, akpm@osdl.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
To: christoph@lameter.com
In-Reply-To: <Pine.LNX.4.62.0506231953260.28244@graphe.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 23 Jun 2005 20:04:52 -0700 (PDT)

> The patch also removes the atomic_dec_and_test in dst_destroy.

That is the only part of this patch I'm willing to entertain
at this time, as long as Herbert Xu ACKs it.  How much of that
quoted %3 gain does this change alone give you?

Also, please post networking patches to netdev@vger.kernel.org.
Because you didn't, the majority of the networking maintainers
did not see your dst patch submissions.  It's mentioned in
linux/MAINTAINERS for a reason:

	NETWORKING [GENERAL]
	P:	Networking Team
	M:	netdev@vger.kernel.org
	L:	netdev@vger.kernel.org
	S:	Maintained

Thanks.
