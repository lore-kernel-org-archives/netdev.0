From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: myri10ge: convert to hw_features
Date: Mon, 18 Apr 2011 13:03:47 +0200
Message-ID: <20110418110347.GA18324@rere.qmqm.pl>
References: <20110415145050.0D65C13A66@rere.qmqm.pl> <20110415182922.GA2458@myri.com> <20110417.233053.70188684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jon.mason@myri.com, netdev@vger.kernel.org, gallatin@myri.com,
	brice@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:36350 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159Ab1DRLDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 07:03:48 -0400
Content-Disposition: inline
In-Reply-To: <20110417.233053.70188684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 17, 2011 at 11:30:53PM -0700, David Miller wrote:
> From: Jon Mason <jon.mason@myri.com>
> Date: Fri, 15 Apr 2011 13:29:22 -0500
>=20
> > On Fri, Apr 15, 2011 at 04:50:50PM +0200, Micha=B3 Miros=B3aw wrote=
:
> >> Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> >> ---
> >>  drivers/net/myri10ge/myri10ge.c |   66 +++++++-------------------=
------------
> >>  1 files changed, 12 insertions(+), 54 deletions(-)
> >>=20
> >> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10g=
e/myri10ge.c
> >> index 1446de5..a48eb92 100644
> >> --- a/drivers/net/myri10ge/myri10ge.c
> >> +++ b/drivers/net/myri10ge/myri10ge.c
> >> @@ -205,7 +205,6 @@ struct myri10ge_priv {
> >>  	int tx_boundary;	/* boundary transmits cannot cross */
> >>  	int num_slices;
> >>  	int running;		/* running?             */
> >> -	int csum_flag;		/* rx_csums?            */
> > Get rid of MXGEFW_FLAGS_CKSUM in drivers/net/myri10ge/myri10ge_mcp.=
h,
> > as this was the only thing using it.
>  ...
> > ethtool_op_set_tso does not support TSO6.  This would remove the
> > enable/disable of that feature.
> Micha=B3 please fix these issues and resubmit this patch, thanks!

There are no issues. MXGEFW_FLAGS_CKSUM is used elsewhere in the driver
and TSO6 is handled by masking netdev->hw_features at devinit time.

BTW, ethtool_op_set_tso() is not used at all in new offload changing sc=
heme.

Best Regards,
Micha=B3 Miros=B3aw
