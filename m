From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 11/12] headers, scc: Add missing #include to <linux/scc.h>
Date: Tue, 09 Aug 2011 09:14:37 +0200
Message-ID: <4E40DE5D.4040100@bfs.de>
References: <1312809302.2591.1139.camel@deadeye> <1312809869.2591.1151.camel@deadeye> <20110808182018.GG29924@decadent.org.uk>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Joerg Reuter <jreuter@yaina.de>,
	Klaus Kudielka <klaus.kudielka@ieee.org>,
	linux-hams@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20110808182018.GG29924@decadent.org.uk>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 08.08.2011 20:20, schrieb Ben Hutchings:
> On Mon, Aug 08, 2011 at 02:24:29PM +0100, Ben Hutchings wrote:
>> <linux/scc.h> uses SIOCDEVPRIVATE, defined in <linux/sockios.h>.
>  
> Unfortunately SIOCDEVPRIVATE is also defined elsewhere by glibc,
> so including <linux/sockios.h> can result in duplicate definitions.
> So I don't think we can make this change.
> 

Maybe that is something the glibc and the kernel guys should know about.
Did someone tell them ? Is that problem documented somewhere ?

re,
 wh


> Ben.
> 
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>> ---
>> This file isn't listed in MAINTAINERS but appears to be associated with
>> one of the hamradio drivers; please could one of the hams claim it?
>>
>> Ben.
>>
>>  include/linux/scc.h |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/scc.h b/include/linux/scc.h
>> index 3495bd9..d5916e5 100644
>> --- a/include/linux/scc.h
>> +++ b/include/linux/scc.h
>> @@ -3,6 +3,7 @@
>>  #ifndef	_SCC_H
>>  #define	_SCC_H
>>  
>> +#include <linux/sockios.h>
>>  
>>  /* selection of hardware types */
>>  
>> -- 
>> 1.7.5.4
>>
>>
>>
> 
