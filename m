From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netns: fix net_alloc_generic()
Date: Fri, 27 Jan 2012 07:09:07 +0100
Message-ID: <1327644547.2919.11.camel@edumazet-laptop>
References: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
	 <1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1327574498.2500.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F212E7E.2040801@parallels.com>
	 <1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <m1zkdacbsx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>,
	"levinsasha928@gmail.com" <levinsasha928@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davej@redhat.com" <davej@redhat.com>,
	"sjurbren@gmail.com" <sjurbren@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1zkdacbsx.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 janvier 2012 =C3=A0 14:57 -0800, Eric W. Biederman a =C3=A9=
crit :

> It is not a chicken and egg problem.  It is a bug in caif.
> caif is claiming to be a network device when it is acting as a subsyt=
em.
> That means it is being initialized too late.
>=20

Ah ok !

> Untested but this should trivially fix the problem, and a bunch
> of others of the same ilk.
>=20

Hmm, please refrain from using "trivially" or "trivial", you're not
fooling anyone.

Truth is this netns layer is horribly complex, since this CAIF bug
needed no more than four patch attempts and lastly your own work before
finding the root cause.

Thanks
