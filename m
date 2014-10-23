From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH] igb: don't reuse pages with pfmemalloc flag
Date: Thu, 23 Oct 2014 15:21:12 +0400
Message-ID: <1811414063272@webcorp02e.yandex-team.ru>
References: <1413985819-9553-1-git-send-email-klamm@yandex-team.ru> <1413992737.9031.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"carolyn.wyborny@intel.com" <carolyn.wyborny@intel.com>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"gregory.v.rose@intel.com" <gregory.v.rose@intel.com>,
	"peter.p.waskiewicz.jr@intel.com" <peter.p.waskiewicz.jr@intel.com>,
	"alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"tushar.n.dave@intel.com" <tushar.n.dave@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sassmann@kpanic.de" <sassmann@kpanic.de>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.or
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413992737.9031.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Interesting...
>
> It seems we also need to clear skb->pfmemalloc in napi_reuse_skb()

Sounds reasonable, but are you sure, that we can just drop skb->pfmemal=
loc flag in napi_reuse_skb()?

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =9Ahttp://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =9Ahttp://www.tux.org/lkml/
