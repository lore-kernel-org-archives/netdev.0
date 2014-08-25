From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/17] tipc: Fix build.
Date: Mon, 25 Aug 2014 11:44:20 -0700 (PDT)
Message-ID: <20140825.114420.77676883396367108.davem@davemloft.net>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
	<1408745360-23560-3-git-send-email-jon.maloy@ericsson.com>
	<20140825102142.GA7151@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbaHYSoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 14:44:23 -0400
In-Reply-To: <20140825102142.GA7151@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 25 Aug 2014 06:21:42 -0400

> On Fri, Aug 22, 2014 at 06:09:05PM -0400, Jon Maloy wrote:
>> From: "David S. Miller" <davem@davemloft.net>
>> 
>> Missing semicolon in range check fix.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
>> ---
>>  net/tipc/port.h |    3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/tipc/port.h b/net/tipc/port.h
>> index a69118f..3087da3 100644
>> --- a/net/tipc/port.h
>> +++ b/net/tipc/port.h
>> @@ -182,8 +182,9 @@ static inline int tipc_port_importance(struct tipc_port *port)
>>  static inline int tipc_port_set_importance(struct tipc_port *port, int imp)
>>  {
>>  	if (imp > TIPC_CRITICAL_IMPORTANCE)
>> -		return -EINVAL
>> +		return -EINVAL;
>>  	msg_set_importance(&port->phdr, (u32)imp);
>> +	return 0;
>>  }
>>  
> Fold this in with the previous patch to avoid a FTBFS during a bisect.

See his header posting, these are changes already in mainline that hadn't
hit net-next yet.
