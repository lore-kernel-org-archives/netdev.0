From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/3] gianfar: Delete unnecessary variable
 initialisations in gfar_ethflow_to_filer_table()
Date: Fri, 15 Jan 2016 11:42:53 -0500 (EST)
Message-ID: <20160115.114253.673366436532953675.davem@davemloft.net>
References: <5698C61A.90504@users.sourceforge.net>
	<20160115102947.GI4764@mwanda>
	<5698D949.6000404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	claudiu.manoil@freescale.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5698D949.6000404@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 15 Jan 2016 12:34:33 +0100

>>> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>>> @@ -768,12 +768,12 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
>>>  static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
>>>  				       u64 class)
>>>  {
>>> -	unsigned int last_rule_idx = priv->cur_filer_idx;
>>> +	unsigned int last_rule_idx;
>> 
>> This is a write only variable.  We can just remove it.
> 
> Can a static source code analysis tool like the software "http://smatch.sourceforge.net/"
> detect that such a variable is not read by this function implementation so far?

No, but a human can.

And a human should fully analyze any change he writes based upon static
analysis tool results.

I am going to be honest, and say that I am completely ignoring most of
your static checker patches.  You don't put enough care and consideration
into them, and I really don't have time to waste on looking at something
like that.
