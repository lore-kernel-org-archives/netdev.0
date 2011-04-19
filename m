From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: xen-netback: convert to hw_features
Date: Tue, 19 Apr 2011 15:30:19 +0200
Message-ID: <20110419133019.GA3973@rere.qmqm.pl>
References: <20110419115612.C4ACA13909@rere.qmqm.pl> <1303219073.5997.191.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60410 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab1DSNaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 09:30:21 -0400
Content-Disposition: inline
In-Reply-To: <1303219073.5997.191.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2011 at 02:17:53PM +0100, Ian Campbell wrote:
> On Tue, 2011-04-19 at 12:56 +0100, Micha=B3 Miros=B3aw wrote:
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Thanks for beating me to this! However the prototype for
> xenvif_fix_features is wrong (needs to take a net_device not a xenvif=
).

I'll resend v2 with this fix.

> I fixed it with the following, I also moved the !can_sg MTU clamping
> into a set_features hook (like we do with netfront). Am I right that
> this pattern copes with changes to SG via ethtool etc better? I think
> it's more future proof in any case.

This looks wrong. Even if SG is turned on, you might get big skbs which
are linearized. There is a difference in SG capability and SG offload
status and as I see it the capability is what you need to test for MTU.

> NB: I'm having some issues with my test hardware at the moment so thi=
s
> is reviewed by eye and compile tested only...
>=20
> I'm also happy for this to be folded into the original with my
> "Signed-off-/Acked-by Ian Campbell <ian.campbell@citrix.com>" if that=
 is
> preferable.

Thanks.

Best Regards,
Micha=B3 Miros=B3aw
