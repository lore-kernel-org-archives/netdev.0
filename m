From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Sat, 28 May 2011 09:35:25 +0200
Message-ID: <20110528073525.GA19033@rere.qmqm.pl>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
 <20110519100331.GA25103@rere.qmqm.pl>
 <20110524091437.GA10779@rere.qmqm.pl>
 <20110524.153930.610330240390616957.davem@davemloft.net>
 <20110524215923.GA20138@rere.qmqm.pl>
 <1306505626.2759.4.camel@bwh-desktop>
 <20110527152809.GA7620@rere.qmqm.pl>
 <1306511150.2759.17.camel@bwh-desktop>
 <20110527163409.GA8497@rere.qmqm.pl>
 <1306538755.2759.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:36071 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128Ab1E1Hf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2011 03:35:26 -0400
Content-Disposition: inline
In-Reply-To: <1306538755.2759.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 28, 2011 at 12:25:55AM +0100, Ben Hutchings wrote:
> On Fri, 2011-05-27 at 18:34 +0200, Micha=B3 Miros=B3aw wrote:
> > On Fri, May 27, 2011 at 04:45:50PM +0100, Ben Hutchings wrote:
> > > On Fri, 2011-05-27 at 17:28 +0200, Micha=B3 Miros=B3aw wrote:
> [...]
> > > >      (note: ETHTOOL_S{SG,...} are not ever going away)
> > > >    - causes NETIF_F_* to be an ABI
> > > If feature flag numbers are not stable then what is the point of
> > > /sys/class/net/<name>/features?  Also, I'm not aware that feature=
s have
> > > ever been renumbered in the past.
> > Since no NETIF_F_* were exported earlier, I assume /sys/class/net/*=
/features
> > is a debugging aid. What is it used for besides that?
> xen-api <https://github.com/xen-org/xen-api> uses it in
> scripts/InterfaceReconfigureVswitch.py.  Though it doesn't seem to be
> used for a particularly good reason...

Look like it should use ETHTOOL_GFLAGS instead for netdev_has_vlan_acce=
l().

Best Regards,
Micha=B3 Miros=B3aw

[added Cc: xen-devel]
