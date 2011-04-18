From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: myri10ge: convert to hw_features
Date: Sun, 17 Apr 2011 23:30:53 -0700 (PDT)
Message-ID: <20110417.233053.70188684.davem@davemloft.net>
References: <20110415145050.0D65C13A66@rere.qmqm.pl>
	<20110415182922.GA2458@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org, gallatin@myri.com,
	brice@myri.com
To: jon.mason@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34885
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751911Ab1DRGb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 02:31:28 -0400
In-Reply-To: <20110415182922.GA2458@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jon Mason <jon.mason@myri.com>
Date: Fri, 15 Apr 2011 13:29:22 -0500

> On Fri, Apr 15, 2011 at 04:50:50PM +0200, Micha=A9=A9 Miros=A9=A9aw w=
rote:
>> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>> ---
>>  drivers/net/myri10ge/myri10ge.c |   66 +++++++---------------------=
----------
>>  1 files changed, 12 insertions(+), 54 deletions(-)
>>=20
>> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/=
myri10ge.c
>> index 1446de5..a48eb92 100644
>> --- a/drivers/net/myri10ge/myri10ge.c
>> +++ b/drivers/net/myri10ge/myri10ge.c
>> @@ -205,7 +205,6 @@ struct myri10ge_priv {
>>  	int tx_boundary;	/* boundary transmits cannot cross */
>>  	int num_slices;
>>  	int running;		/* running?             */
>> -	int csum_flag;		/* rx_csums?            */
>=20
> Get rid of MXGEFW_FLAGS_CKSUM in drivers/net/myri10ge/myri10ge_mcp.h,
> as this was the only thing using it.
 ...
> ethtool_op_set_tso does not support TSO6.  This would remove the
> enable/disable of that feature.

Micha=A9=A9 please fix these issues and resubmit this patch, thanks!
