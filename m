From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: bnx2x: Added EEE support
Date: Mon, 22 Oct 2012 14:15:35 +0200
Message-ID: <508538E7.7020609@broadcom.com>
References: <20120608130921.GA19268@elgon.mountain>
 <979A8436335E3744ADCD3A9F2A2B68A5027223@SJEXCHMB10.corp.ad.broadcom.com>
 <20121022120647.GC7380@mwanda>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4705 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451Ab2JVMRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 08:17:25 -0400
In-Reply-To: <20121022120647.GC7380@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sun, Jun 10, 2012 at 07:47:13AM +0000, Yuval Mintz wrote:
>>> The patch c8c60d88c59c: "bnx2x: Added EEE support" from Jun 6, 2012,
>>> leads to the following warning:
>>> drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:10121
>>> bnx2x_848x3_config_init()
>>> 	 error: buffer overflow 'params->req_duplex' 2 <= 4
>>>
>>
>> Hi Dan,
>>
>> You are right - this is indeed an error, although one that shouldn't
>> affect any existing bnx2x chip supporting EEE.
>>
>> I'll send a patch correcting it soon.
>>
> 
> What happened with this?
> 
> regards,
> dan carpenter
> 
> 

The patch will be sent upstream in the next couple of days.

Thanks,
Yuval
