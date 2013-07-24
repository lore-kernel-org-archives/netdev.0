From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] net: trans_rdma: remove unused function
Date: Thu, 25 Jul 2013 01:09:47 +0200
Message-ID: <1374707387.29835.23.camel@x61.thuisdomein>
References: <1374497956-32104-1-git-send-email-andi@etezian.org>
	 <20130724.154646.2283898956674234778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@etezian.org, ericvh@gmail.com, rminnich@sandia.gov,
	lucho@ionkov.net, v9fs-developer@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130724.154646.2283898956674234778.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-24 at 15:46 -0700, David Miller wrote:
> From: Andi Shyti <andi@etezian.org>
> > This patch gets rid of the following warning:
> >=20
> > net/9p/trans_rdma.c:594:12: warning: =E2=80=98rdma_cancelled=E2=80=99=
 defined but not used [-Wunused-function]
> >  static int rdma_cancelled(struct p9_client *client, struct p9_req_=
t *req)
> >=20
> > The rdma_cancelled function is not called anywhere in the kernel
> >=20
> > Signed-off-by: Andi Shyti <andi@etezian.org>
>=20
> Applied to net-next, thanks.

After this patch one might as well revert the rest of commit
80b45261a0b2 ("9P: Add cancelled() to the transport functions.") too. I=
t
seems the entire cancelled callback stuff is now pointless.

As I already asked in https://lkml.org/lkml/2013/7/15/87 : did that
commit "forget to actually hook up rdma_cancelled() into
p9_rdma_trans()?". It does look so to me.


Paul Bolle
