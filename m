From: Yann Droneaud <ydroneaud@opteya.com>
Subject: Re: [patch] RDMA/cxgb4: info leak in c4iw_alloc_ucontext()
Date: Sun, 04 May 2014 23:46:30 +0200
Message-ID: <1399239990.2957.6.camel@localhost.localdomain>
References: <20140328082428.GH25192@mwanda>
	 <1396002468.3297.63.camel@localhost.localdomain>
	 <20140502235616.GJ4963@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Wise <swise@chelsio.com>, Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	roland@purestorage.com, dm@chelsio.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com, Steve Wise <swise@opengridcomputing.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140502235616.GJ4963@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Le samedi 03 mai 2014 =C3=A0 02:56 +0300, Dan Carpenter a =C3=A9crit :
> On Fri, Mar 28, 2014 at 11:27:48AM +0100, Yann Droneaud wrote:
> > Unfortunately, it's not the only structure which has this problem. =
I'm
> > currently preparing a report on this issue for this driver (cxgb4) =
and
> > another.
> >=20
>=20
> This information leak is still present in linux-next.  These days we
> count those things as security vulnerabilities with CVEs and everythi=
ng.
>=20
> When is it likely to get fixed?
>=20

Thanks for the reminder.

The patches were waiting for some times in my patch queue, I failed to
provide them earlier. BTW, I've taken time during the week end to
complete them. They should be available on linux-rdma@vger.kernel.org.
See http://marc.info/?i=3Dcover.1399216475.git.ydroneaud@opteya.com

Regards.

--=20
Yann Droneaud
OPTEYA


--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
