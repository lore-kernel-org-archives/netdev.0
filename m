From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: fix const array syntax
Date: Fri, 01 Jul 2011 16:15:30 -0700 (PDT)
Message-ID: <20110701.161530.405101095066596400.davem@davemloft.net>
References: <1309560635-17514-1-git-send-email-Gregory.Dietsche@cuw.edu>
	<4E0E546B.3000106@cuw.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, kernel-janitors@vger.kernel.org
To: gregory.dietsche@cuw.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073Ab1GAXPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 19:15:37 -0400
In-Reply-To: <4E0E546B.3000106@cuw.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Dietsche <gregory.dietsche@cuw.edu>
Date: Fri, 01 Jul 2011 18:12:43 -0500

> On 07/01/2011 05:50 PM, Greg Dietsche wrote:
>> Correct the syntax so that both array and pointer are const.
>>
>> Signed-off-by: Greg Dietsche<Gregory.Dietsche@cuw.edu>
>> ---
>>   net/rds/tcp_stats.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/rds/tcp_stats.c b/net/rds/tcp_stats.c
>> index d5898d0..f8a7954 100644
>> --- a/net/rds/tcp_stats.c
>> +++ b/net/rds/tcp_stats.c
>> @@ -40,7 +40,7 @@
>>   DEFINE_PER_CPU(struct rds_tcp_statistics, rds_tcp_stats)
>>   	____cacheline_aligned;
>>
>> -static const char const *rds_tcp_stat_names[] = {
>> +static const char * const rds_tcp_stat_names[] = {
>>   	"tcp_data_ready_calls",
>>   	"tcp_write_space_calls",
>>   	"tcp_sndbuf_full",
>>    
> Andy's email is bouncing (Recipient unknown)... if someone else could
> pick this up, that'd be great!

I'll take care of it.
