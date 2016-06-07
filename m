From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] bridge: netfilter: checkpatch whitespace fixes
Date: Tue, 07 Jun 2016 10:04:40 -0700
Message-ID: <1465319080.25087.28.camel@perches.com>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
	 <1462843618-21914-2-git-send-email-me@tobin.cc>
	 <20160607151458.GA18008@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>, tcharding <me@tobin.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0221.hostedemail.com ([216.40.44.221]:52876 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755411AbcFGREs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 13:04:48 -0400
In-Reply-To: <20160607151458.GA18008@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-07 at 17:14 +0200, Pablo Neira Ayuso wrote:
> On Tue, May 10, 2016 at 11:26:56AM +1000, tcharding wrote:
> > From: Tobin C Harding <me@tobin.cc>
> > This is my second linux kernel patch. Unsure if I was meant to cc m=
ultiple mailing lists?
[]
> > diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/=
ebt_stp.c
[]
> > @@ -55,65 +55,65 @@ static bool ebt_filter_config(const struct ebt_=
stp_info *info,
> > =A0	if (info->bitmask & EBT_STP_ROOTPRIO) {
> > =A0		v16 =3D NR16(stpc->root);
> > =A0		if (FWINV(v16 < c->root_priol ||
> > -		=A0=A0=A0=A0v16 > c->root_priou, EBT_STP_ROOTPRIO))
> > +			=A0=A0v16 > c->root_priou, EBT_STP_ROOTPRIO))
> I don't think this coding style is right. This is a common approach
> (to align the condition when split in several lines) in other 'net' c=
ode.

Perhaps you misread the code.

The alignment is changed for the 1st argument of the FWINV macro
to be more similar to the style used in the rest of net/

But using a longer initial line would be more readable:

=A0		if (FWINV(v16 < c->root_priol ||=A0v16 > c->root_priou,
			=A0=A0EBT_STP_ROOTPRIO))
