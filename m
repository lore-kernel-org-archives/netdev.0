From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] vhost-net: use lock_sock_fast() in peek_head_len()
Date: Sun, 13 Mar 2011 17:32:07 +0100
Message-ID: <1300033927.2761.26.camel@edumazet-laptop>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	 <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	 <20110313150646.GA30494@redhat.com>
	 <1300031570.2761.22.camel@edumazet-laptop>
	 <20110313161915.GB30642@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Wang <jasowang@redhat.com>, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110313161915.GB30642@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 13 mars 2011 =C3=A0 18:19 +0200, Michael S. Tsirkin a =C3=A9=
crit :

> Other side is in drivers/net/tun.c and net/packet/af_packet.c
> At least wrt tun it seems clear socket is not locked.

Yes (assuming you refer to tun_net_xmit())

> Besides queue, dequeue seems to be done without socket locked.
>=20

It seems this code (assuming you speak of drivers/vhost/net.c ?) has
some races indeed.
