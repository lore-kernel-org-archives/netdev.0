From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 01 Oct 2009 09:43:56 -0700 (PDT)
Message-ID: <20091001.094356.95174955.davem@davemloft.net>
References: <200910011916.40908.cratiu@ixiacom.com>
	<20091001092100.14ea024b@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cratiu@ixiacom.com, netdev@vger.kernel.org, opurdila@ixiacom.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33813
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753292AbZJAQnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 12:43:37 -0400
In-Reply-To: <20091001092100.14ea024b@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 1 Oct 2009 09:21:00 -0700

>> Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
>> --- //packages/linux_2.6.7/main/src/include/linux/sysctl.h
>> +++ /home/z/w1/packages/linux_2.6.7/main/src/include/linux/sysctl.h
>> @@ -444,6 +444,7 @@                                                
>>         NET_IPV6_IP6FRAG_TIME=23,                                  
>>         NET_IPV6_IP6FRAG_SECRET_INTERVAL=24,                       
>>         NET_IPV6_MLD_MAX_MSF=25,                                   
>> +       NET_IPV6_NDISC_FORCE_TLLAO=26,                             
> 
> Since numbered sysctl values are deprecated, can you use CTL_UNNUMBERED
> to avoid having to add yet another value?

Using CLT_UNNUMBERED is a must these days.

Also, please fix the prefixing of the paths in your patch.
See Documentation/SubmittingPatches in the kernel tree.
