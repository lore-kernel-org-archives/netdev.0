From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH 1/3] net-gianfar: Less function calls in
 gfar_ethflow_to_filer_table() after error detection
Date: Fri, 1 Jan 2016 13:50:15 +0100
Message-ID: <56867607.4090907@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56866E7F.8080609@users.sourceforge.net>
 <56866F68.6070904@users.sourceforge.net>
 <alpine.DEB.2.02.1601011334200.2054@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1601011334200.2054@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> @@ -778,11 +778,13 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
>>  
>>  	local_rqfpr = kmalloc_array(MAX_FILER_IDX + 1, sizeof(unsigned int),
>>  				    GFP_KERNEL);
>> +	if (!local_rqfpr)
>> +		return 1;
> 
> Why return 1?  Previously 0 was returned.

You are right. - Unfortunately, I made a mistake at this place
of my update suggestion.


> Normally, one returns -ENOMEM for this case, but it looks like this 
> function is returning 0 on failure.

Should a symbol like "false" be used instead of such a special number?

Regards,
Markus
