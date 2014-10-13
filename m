From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tg3: Add skb->xmit_more support
Date: Mon, 13 Oct 2014 10:14:17 -0700
Message-ID: <543C0869.7000604@hp.com>
References: <1413217302-15396-1-git-send-email-prashant@broadcom.com> <1413218934.9362.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dborkman@redhat.com,
	mchan@broadcom.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Prashant Sreedharan <prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:14855 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbaJMROU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 13:14:20 -0400
In-Reply-To: <1413218934.9362.104.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2014 09:48 AM, Eric Dumazet wrote:
> On Mon, 2014-10-13 at 09:21 -0700, Prashant Sreedharan wrote:
>> Ring TX doorbell only if xmit_more is not set or the queue is stopped.
>>
>> Suggested-by: Daniel Borkmann <dborkman@redhat.com>
>> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>> ---
>>   drivers/net/ethernet/broadcom/tg3.c |   10 ++++++----
>>   1 files changed, 6 insertions(+), 4 deletions(-)
>
> Have you noticed any performance change ?
>
> I did the patch for bnx2x but got no real difference...

If ringing the doorbell is just a pio write, it may just get lost in the 
noise.  If though the programming model (or some sort of defect 
workaround) of the NIC requires a pio read of some sort when ringing the 
doorbell...

rick
