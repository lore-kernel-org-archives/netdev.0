From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: gianfar: Less function calls in gfar_ethflow_to_filer_table()
 after error detection
Date: Fri, 15 Jan 2016 18:32:54 +0100
Message-ID: <56992D46.8070102@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56866E7F.8080609@users.sourceforge.net>
 <5698C53C.8060204@users.sourceforge.net>
 <5698C5CB.80305@users.sourceforge.net> <1452854229.8586.48.camel@perches.com>
 <5698DC52.4050808@users.sourceforge.net>
 <1452859429.8586.52.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452859429.8586.52.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> 	local_rqfpr = kmalloc_array(2 * (MAX_FILER_IDX + 1),
>>> 				    sizeof(unsigned int), GFP_KERNEL);
>>> 	if (!local_rqfpr)
>>> 		goto err;
>>>
>>> 	local_rqfcr = &local_rqfpr[MAX_FILER_IDX + 1];
>>
>> Do you suggest to use only one array (instead of two as before) here?
> 
> That's a possibility.

Thanks for your clarification.


> If, as your title suggests, you really want fewer function calls,

I am unsure at the moment if more changes will make sense in
this function implementation.


> (which as far as I saw, you didn't do)

Is my wording "after error detection" insufficient eventually?


> that could be a mechanism to remove both an allocation and a free.

Would any more software developers or source code reviewers like
to share their opinions in such a direction?

Regards,
Markus
