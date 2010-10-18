From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2/3] cxgb4: function namespace cleanup (v2)
Date: Mon, 18 Oct 2010 09:53:38 -0500
Message-ID: <4CBC5F72.3070005@opengridcomputing.com>
References: <20101015224309.179898823@vyatta.com>	<20101015224523.633775810@vyatta.com>	<20101015171057.409db0f2@nehalam>	<4CB8FBCE.3090401@chelsio.com>	<20101015212310.47a74d86@nehalam>	<4CB9434D.1060702@chelsio.com>	<4CBA6DC8.4010104@opengridcomputing.com> <20101018074713.0d0b91fd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Casey Leedom <leedom@chelsio.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:60180 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756481Ab0JROxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 10:53:45 -0400
In-Reply-To: <20101018074713.0d0b91fd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2010 09:47 AM, Stephen Hemminger wrote:
> On Sat, 16 Oct 2010 22:30:16 -0500
> Steve Wise<swise@opengridcomputing.com>  wrote:
>
>    
>> On 10/16/2010 1:16 AM, Dimitris Michailidis wrote:
>>      
>>> Stephen Hemminger wrote:
>>>        
>>>> On Fri, 15 Oct 2010 18:11:42 -0700
>>>> Dimitris Michailidis<dm@chelsio.com>  wrote:
>>>>
>>>>          
>>>>> Stephen Hemminger wrote:
>>>>>            
>>>>>> Make functions only used in one file local.
>>>>>> Remove lots of dead code, relating to unsupported functions
>>>>>> in mainline driver like RSS, IPv6, and TCP offload.
>>>>>>              
>>>>> Thanks, this looks OK.  One exception, cxgb4_get_tcp_stats was
>>>>> intended to be used by the rdma driver.  I see that driver doesn't
>>>>> call it presently but if you don't mind can we give Steve a few
>>>>> hours to tell us if he has any imminent plans to use it.  If he
>>>>> doesn't offer to do something to use it for .37 it goes.
>>>>>            
>>>> The kernel source tree is not your development place holder tree.
>>>> At least #ifdef the code out for now.
>>>>          
>>> I am trying to protect Stephen Rothwell's time by checking that the IB
>>> folks don't plan to add a call to this in their tree while we remove
>>> the function in net-next.  There's supposed to be a call in the IB
>>> driver.  I don't know why there isn't one or whether they are planning
>>> to fix it for .37.  I see the potential for a linux-next conflict and
>>> I am trying to avoid it.  #ifdef doesn't help, if it's not needed we
>>> can remove it for good.
>>>        
>> I'll add a patch this week to utilize the tcp stats.
>>      
> In cxgb4 only or both cxgb3 and cxgb4?
>    

iw_cxgb3 already uses the cxgb3 TCP MIB.


Steve.

