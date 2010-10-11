From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v12 06/17] Use callback to deal with skb_release_data()
 specially.
Date: Mon, 11 Oct 2010 17:42:11 +0200
Message-ID: <1286811731.2737.28.camel@edumazet-laptop>
References: <f2bf65a8a7676bbd3e8a749ae93d99e88671d35d.1285853725.git.xiaohui.xin@intel.com>
	 <20101001.001439.85411154.davem@davemloft.net>
	 <F2E9EB7348B8264F86B6AB8151CE2D793064B2A9D8@shsmsx502.ccr.corp.intel.com>
	 <20101011.082728.193709462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101011.082728.193709462.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 11 octobre 2010 =C3=A0 08:27 -0700, David Miller a =C3=A9crit =
:
> From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
> Date: Mon, 11 Oct 2010 15:06:05 +0800
>=20
> > That's to avoid the new cache miss caused by using destructor_arg i=
n data path
> > like skb_release_data().
> > That's based on the comment from Eric Dumazet on v7 patches.
>=20
> Thanks for the explanation.

Anyway, frags[] must be the last field of "struct skb_shared_info"
since commit fed66381 (net: pskb_expand_head() optimization)

It seems Xin worked on a quite old tree.
