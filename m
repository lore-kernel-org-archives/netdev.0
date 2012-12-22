From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Sat, 22 Dec 2012 15:04:01 +0100
Message-ID: <20121222140401.GE17461@breakpoint.cc>
References: <50D1AB7E.5060000@mojatatu.com>
 <50D2D229.6040802@gmail.com>
 <50D305FD.7000901@mojatatu.com>
 <50D327CD.3050904@gmail.com>
 <50D45E25.7050703@mojatatu.com>
 <50D46060.2070308@gmail.com>
 <50D46928.9070809@mojatatu.com>
 <50D46EC1.2040608@gmail.com>
 <50D5B366.30005@mojatatu.com>
 <50D5BC96.9010602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Yury Stankevich <urykhy@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50D5BC96.9010602@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yury Stankevich <urykhy@gmail.com> wrote:
> 22.12.2012 17:19, Jamal Hadi Salim =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > From the description Jan provided in his response, I dont
> > think this used to work at all. Are you saying it worked before?
>=20
> no.
> i'm trying if this can work, alas. it can't.

Yury, what are you trying to accomplish?
Is there a particular reason why you want to use ingress shaping
instead of pure policing?

I ask, because you could try to use hashlimit match to do
rate policing via netfilter.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
