From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH net-next v3] af_unix: Fix use-after-free crashes
Date: Thu, 08 Sep 2011 01:37:45 -0700
Message-ID: <1315471065.2301.1.camel@schen9-mobl>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	 <1315372100.3400.76.camel@edumazet-laptop> <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
	 <CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>
	 <CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com>
	 <1315406256.6287.7.camel@schen9-mobl> <4E680BF1.8000901@intel.com>
	 <1315429583.2361.3.camel@schen9-mobl>
	 <1315461572.2532.7.camel@edumazet-laptop> <4E685F19.6030407@intel.com>
	 <1315465919.2532.19.camel@edumazet-laptop> <4E686D71.30603@intel.com>
	 <1315467184.2532.22.camel@edumazet-laptop>
	 <CA+icZUWH8953m4qs74JLhNwrzJM0eMfE8aizJ1XtuVFFTtLKqg@mail.gmail.com>
	 <1315488103.2456.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sedat.dilek@gmail.com, "Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59769 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303Ab1IHPhr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 11:37:47 -0400
In-Reply-To: <1315488103.2456.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-08 at 15:21 +0200, Eric Dumazet wrote:
> Le jeudi 08 septembre 2011 =C3=A0 11:59 +0200, Sedat Dilek a =C3=A9cr=
it :
>=20
> > I have tested this fixup patch on i386.
> > Can we have a separate patch with corrected descriptive text?
> >=20
> > Thanks to all involved people.
>=20
> Here it is :
>=20
> [PATCH net-next v3] af_unix: Fix use-after-free crashes
>=20
> Commit 0856a30409 (Scm: Remove unnecessary pid & credential reference=
s
> in Unix socket's send and receive path) introduced an use-after-free
> bug.
>=20
> We are allowed to steal the references to pid/cred only in the last s=
kb
> sent from unix_stream_sendmsg(), because first skbs might be consumed=
 by
> the receiver before we finish our sendmsg() call.
>=20
> Remove scm_release() helper, since its cleaner to clear pid/cred fiel=
ds
> in unix_scm_to_skb() when we steal them.
>=20
> Based on prior patches from Yan Zheng and Tim Chen
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Jiri Slaby <jirislaby@gmail.com>
> Tested-by: Sedat Dilek <sedat.dilek@googlemail.com>
> Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> ---

Thanks.

Acked-by: Tim Chen <tim.c.chen@linux.intel.com>
