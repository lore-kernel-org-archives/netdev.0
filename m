From: Tushar Behera <tushar.behera@linaro.org>
Subject: Re: [PATCH 08/14] xen: netback: Remove redundant check on unsigned
 variable
Date: Fri, 28 Dec 2012 10:45:39 +0530
Message-ID: <50DD2AFB.6030701@linaro.org>
References: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>  <1353048646-10935-9-git-send-email-tushar.behera@linaro.org> <1353057394.3499.159.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"patches@linaro.org" <patches@linaro.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61054 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab2L1FPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 00:15:46 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so5690551pbc.5
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 21:15:45 -0800 (PST)
In-Reply-To: <1353057394.3499.159.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2012 02:46 PM, Ian Campbell wrote:
> On Fri, 2012-11-16 at 06:50 +0000, Tushar Behera wrote:
>> No need to check whether unsigned variable is less than 0.
>>
>> CC: Ian Campbell <ian.campbell@citrix.com>
>> CC: xen-devel@lists.xensource.com
>> CC: netdev@vger.kernel.org
>> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> 
> Thanks.
> 

This patch was not picked up for 3.8-rc1. Any idea, who should pick this up?

>> ---
>>  drivers/net/xen-netback/netback.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index aab8677..515e10c 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -190,14 +190,14 @@ static int get_page_ext(struct page *pg,
>>  
>>  	group = ext.e.group - 1;
>>  
>> -	if (group < 0 || group >= xen_netbk_group_nr)
>> +	if (group >= xen_netbk_group_nr)
>>  		return 0;
>>  
>>  	netbk = &xen_netbk[group];
>>  
>>  	idx = ext.e.idx;
>>  
>> -	if ((idx < 0) || (idx >= MAX_PENDING_REQS))
>> +	if (idx >= MAX_PENDING_REQS)
>>  		return 0;
>>  
>>  	if (netbk->mmap_pages[idx] != pg)
> 
> 


-- 
Tushar Behera
