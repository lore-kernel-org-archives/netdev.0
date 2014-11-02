From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH] bridge: fix netfilter/NF_BR_LOCAL_OUT for own, locally
 generated queries
Date: Sun, 2 Nov 2014 16:37:33 +0100
Message-ID: <20141102153733.GA23084@odroid>
References: <1411342364-4791-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1411342364-4791-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 22, 2014 at 01:32:44AM +0200, Linus L=C3=BCssing wrote:
> Ebtables on the OUTPUT chain (NF_BR_LOCAL_OUT) would not work as expe=
cted
> for both locally generated IGMP and MLD queries. The IP header specif=
ic
> filter options are off by 14 Bytes for netfilter (actual output on
> interfaces is fine).
>=20
> NF_HOOK()=E2=80=AFexpects the skb->data to point to the IP header, no=
t the
> ethernet one (while dev_queue_xmit()=E2=80=AFdoes not). Luckily there=
 is an
> br_dev_queue_push_xmit() helper function already - let's just use tha=
t.

bump
