From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 3/4] netfilter: Fix portid types
Date: Fri, 13 Mar 2015 14:19:57 +0100
Message-ID: <5502E3FD.50803@nod.at>
References: <1426246276-15839-1-git-send-email-richard@nod.at> <1426246276-15839-4-git-send-email-richard@nod.at> <20150313130155.GA1044@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, sameo@linux.intel.com,
	aloisio.almeida@openbossa.org, lauro.venancio@openbossa.org,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150313130155.GA1044@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 13.03.2015 um 14:01 schrieb Pablo Neira Ayuso:
> On Fri, Mar 13, 2015 at 12:31:15PM +0100, Richard Weinberger wrote:
>> The netlink portid is an unsigned integer, use this type
>> also in netfilter.
> 
> This small cleanup I can still take it but...
> 
>> Signed-off-by: Richard Weinberger <richard@nod.at>
>> ---
>>  net/netfilter/nfnetlink_log.c        | 4 ++--
>>  net/netfilter/nfnetlink_queue_core.c | 7 ++++---
>>  2 files changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
>> index 11d85b3..7f00846 100644
>> --- a/net/netfilter/nfnetlink_log.c
>> +++ b/net/netfilter/nfnetlink_log.c
>> @@ -62,7 +62,7 @@ struct nfulnl_instance {
>>  	struct timer_list timer;
>>  	struct net *net;
>>  	struct user_namespace *peer_user_ns;	/* User namespace of the peer process */
>> -	int peer_portid;			/* PORTID of the peer process */
>> +	unsigned int peer_portid;		/* PORTID of the peer process */
> 
> I think you have to use u32 for consistency. Other spots use the
> datatype for the netlink portid.
> 
> I think same thing applies to other patches.

Of course! Will re-spin with u32.

Thanks,
//richard
