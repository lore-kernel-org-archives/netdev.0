From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: myri10ge: convert to hw_features
Date: Mon, 18 Apr 2011 22:49:26 -0700 (PDT)
Message-ID: <20110418.224926.104049057.davem@davemloft.net>
References: <20110415182922.GA2458@myri.com>
	<20110417.233053.70188684.davem@davemloft.net>
	<20110418110347.GA18324@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jon.mason@myri.com, netdev@vger.kernel.org, gallatin@myri.com,
	brice@myri.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34150
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750796Ab1DSFuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 01:50:01 -0400
In-Reply-To: <20110418110347.GA18324@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Mon, 18 Apr 2011 13:03:47 +0200

> On Sun, Apr 17, 2011 at 11:30:53PM -0700, David Miller wrote:
>> From: Jon Mason <jon.mason@myri.com>
>> Date: Fri, 15 Apr 2011 13:29:22 -0500
>>=20
>> > On Fri, Apr 15, 2011 at 04:50:50PM +0200, Micha=A9=A9 Miros=A9=A9a=
w wrote:
>> >> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl=
>
>> >> ---
>> >>  drivers/net/myri10ge/myri10ge.c |   66 +++++++------------------=
-------------
>> >>  1 files changed, 12 insertions(+), 54 deletions(-)
>> >>=20
>> >> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10=
ge/myri10ge.c
>> >> index 1446de5..a48eb92 100644
>> >> --- a/drivers/net/myri10ge/myri10ge.c
>> >> +++ b/drivers/net/myri10ge/myri10ge.c
>> >> @@ -205,7 +205,6 @@ struct myri10ge_priv {
>> >>  	int tx_boundary;	/* boundary transmits cannot cross */
>> >>  	int num_slices;
>> >>  	int running;		/* running?             */
>> >> -	int csum_flag;		/* rx_csums?            */
>> > Get rid of MXGEFW_FLAGS_CKSUM in drivers/net/myri10ge/myri10ge_mcp=
=2Eh,
>> > as this was the only thing using it.
>>  ...
>> > ethtool_op_set_tso does not support TSO6.  This would remove the
>> > enable/disable of that feature.
>> Micha=A9=A9 please fix these issues and resubmit this patch, thanks!
>=20
> There are no issues. MXGEFW_FLAGS_CKSUM is used elsewhere in the driv=
er
> and TSO6 is handled by masking netdev->hw_features at devinit time.
>=20
> BTW, ethtool_op_set_tso() is not used at all in new offload changing =
scheme.

Ok, applied, thanks!

