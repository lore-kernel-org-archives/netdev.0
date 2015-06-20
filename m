From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/32] Netfilter updates for net-next
Date: Sat, 20 Jun 2015 20:30:06 +0200
Message-ID: <20150620183006.GA3362@salvia>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
 <20150620151130.74b68b6c@north>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bernhard Thaler <bernhard.thaler@wvnet.at>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>
To: Jakub =?utf-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150620151130.74b68b6c@north>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 20, 2015 at 03:11:30PM +0200, Jakub Kici=C5=84ski wrote:
> On Mon, 15 Jun 2015 23:25:57 +0200, Pablo Neira Ayuso wrote:
> > Hi David,
> >=20
> > This a bit large (and late) patchset that contains Netfilter update=
s for
> > net-next. Most relevantly br_netfilter fixes, ipset RCU support, re=
moval of
> > x_tables percpu ruleset copy and rework of the nf_tables netdev sup=
port. More
> > specifically, they are:
> [...]
> > ----------------------------------------------------------------
> > Bernhard Thaler (7):
> >       netfilter: bridge: refactor clearing BRNF_NF_BRIDGE_PREROUTIN=
G
> >       netfilter: bridge: re-order br_nf_pre_routing_finish_ipv6()
> >       netfilter: bridge: detect NAT66 correctly and change MAC addr=
ess
> >       netfilter: bridge: refactor frag_max_size
> >       netfilter: bridge: rename br_parse_ip_options
> >       netfilter: bridge: re-order check_hbh_len()
> >       netfilter: bridge: forward IPv6 fragmented packets
>=20
> Pablo, Bernhard,
>=20
> this batch breaks builds with CONFIG_IPV6=3Dn.  No idea why build bot
> didn't catch that.

There is a pending pull request to address this fallout:

http://patchwork.ozlabs.org/patch/486819/

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
