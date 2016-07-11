From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] sctp: implement rfc7496 in sctp
Date: Mon, 11 Jul 2016 13:25:51 -0700 (PDT)
Message-ID: <20160711.132551.463700196393147415.davem@davemloft.net>
References: <cover.1468064737.git.lucien.xin@gmail.com>
	<20160711161529.GA9950@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	daniel@iogearbox.net
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbcGKUZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:25:55 -0400
In-Reply-To: <20160711161529.GA9950@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon, 11 Jul 2016 13:15:29 -0300

> On Sat, Jul 09, 2016 at 07:47:39PM +0800, Xin Long wrote:
>> This patchset implements "Additional Policies for the Partially Reliable
>> Stream Control Transmission Protocol Extension" described on RFC7496.
>> 
>> The Partially Reliable SCTP (PR-SCTP) extension defined in [RFC3758]
>> provides a generic method for senders to abandon user messages. The
>> decision to abandon a user message is sender side only, and the exact
>> condition is called a "PR-SCTP policy". This patchset implements 3
>> policies:
>> 
>>  1. Timed Reliability:  This allows the sender to specify a timeout for
>>     a user message after which the SCTP stack abandons the user message.
>> 
>>  2. Limited Retransmission Policy:  Allows limitation of the number of
>>     retransmissions.
>> 
>>  3. Priority Policy:  Allows removal of lower-priority messages if space
>>     for higher-priority messages is needed in the send buffer.
>> 
>> Patch 1-3 add some sockopts in sctp to set/get pr_sctp policy status.
>> Patch 4-6 implement these 3 policies one by one.
>> 
>> Xin Long (6):
>>   sctp: add SCTP_PR_SUPPORTED on sctp sockopt
>>   sctp: add SCTP_DEFAULT_PRINFO into sctp sockopt
>>   sctp: add SCTP_PR_ASSOC_STATUS on sctp sockopt
>>   sctp: implement prsctp TTL policy
>>   sctp: implement prsctp RTX policy
>>   sctp: implement prsctp PRIO policy
> 
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Series applied.
