From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH v3 2/3] gianfar: Delete unnecessary variable
 initialisations in gfar_ethflow_to_filer_table()
Date: Fri, 15 Jan 2016 12:34:33 +0100
Message-ID: <5698D949.6000404@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56866E7F.8080609@users.sourceforge.net>
 <5698C53C.8060204@users.sourceforge.net>
 <5698C61A.90504@users.sourceforge.net> <20160115102947.GI4764@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160115102947.GI4764@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> @@ -768,12 +768,12 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
>>  static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
>>  				       u64 class)
>>  {
>> -	unsigned int last_rule_idx = priv->cur_filer_idx;
>> +	unsigned int last_rule_idx;
> 
> This is a write only variable.  We can just remove it.

Can a static source code analysis tool like the software "http://smatch.sourceforge.net/"
detect that such a variable is not read by this function implementation so far?
https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/drivers/net/ethernet/freescale/gianfar_ethtool.c?id=b75ec3af27bf011a760e2f44eb25a99b6fbb0fb3#n850

Does this place indicate an unwanted value assignment as a leftover,
or are there any other actions missing?

Regards,
Markus
