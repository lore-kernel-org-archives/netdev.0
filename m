From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: check bundle policy existance before
 dereferencing it
Date: Thu, 24 Jun 2010 14:35:32 -0700 (PDT)
Message-ID: <20100624.143532.245414414.davem@davemloft.net>
References: <4C22805A.3080307@gmail.com>
	<1277358319-9868-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, justinmattock@gmail.com,
	eric.dumazet@gmail.com, linville@tuxdriver.com,
	linux-kernel@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277358319-9868-1-git-send-email-timo.teras@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 24 Jun 2010 08:45:19 +0300

> Fix the bundle validation code to not assume having a valid policy.
> When we have multiple transformations for a xfrm policy, the bundle
> instance will be a chain of bundles with only the first one having
> the policy reference. When policy_genid is bumped it will expire the
> first bundle in the chain which is equivalent of expiring the whole
> chain.
>=20
> Reported-bisected-and-tested-by: Justin P. Mattock <justinmattock@gma=
il.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied.
