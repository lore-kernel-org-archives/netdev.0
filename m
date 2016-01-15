From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: gianfar: Less function calls in gfar_ethflow_to_filer_table()
 after error detection
Date: Fri, 15 Jan 2016 12:47:30 +0100
Message-ID: <5698DC52.4050808@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56866E7F.8080609@users.sourceforge.net>
 <5698C53C.8060204@users.sourceforge.net>
 <5698C5CB.80305@users.sourceforge.net> <1452854229.8586.48.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1452854229.8586.48.camel@perches.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> * Return directly if a memory allocation failed at the beginning.
>>
>> * Adjust jump targets according to the Linux coding style convention.
>>
>> This issue was detected by using the Coccinelle software.
> 
> Is this really better?
> 
> Perhaps this particular static analysis isn't too useful.

The opinions are still evolving for such a kind of search pattern.


> Why not just allocate once and assign a second pointer?
> 
> 	local_rqfpr = kmalloc_array(2 * (MAX_FILER_IDX + 1),
> 				    sizeof(unsigned int), GFP_KERNEL);
> 	if (!local_rqfpr)
> 		goto err;
> 
> 	local_rqfcr = &local_rqfpr[MAX_FILER_IDX + 1];

Do you suggest to use only one array (instead of two as before) here?

Regards,
Markus
