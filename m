From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH nf] netfilter: xt_LOG: fix mark logging for IPv6 packets
Date: Wed, 29 May 2013 13:57:02 +0200
Message-ID: <20130529115702.GB3853@unicorn.suse.cz>
References: <20130529084118.6676862C72@unicorn.suse.cz>
 <20130529111822.GA5162@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, coreteam@netfilter.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130529111822.GA5162@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 29, 2013 at 01:18:22PM +0200, Pablo Neira Ayuso wrote:
> On Wed, May 29, 2013 at 10:37:03AM +0200, Michal Kubecek wrote:
> > In dump_ipv6_packet(), the "recurse" parameter is zero only if
> > dumping contents of a packet embedded into an ICMPv6 error
> > message. Therefore we want to log packet mark if recurse is
> > non-zero, not when it is zero.
>=20
> Applied, thanks Michal.
>=20
> The problem seems to be there since the beginning, ie. 2.6.26.

Yes, as far as I can say, the IPv6 part actually never worked.

                                               Michal Kube=E8ek

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
