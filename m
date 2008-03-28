From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: Remove an useless parameter from
Date: Fri, 28 Mar 2008 10:47:20 +0800
Message-ID: <47EC5C38.6030203@cn.fujitsu.com>
References: <47EC4F56.6000300@cn.fujitsu.com> <20080328020754.GN14945@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	vladislav <vladislav.yasevich@hp.com>,
	netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-deve
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57038 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756056AbYC1Cr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 22:47:57 -0400
In-Reply-To: <20080328020754.GN14945@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaldo Carvalho de Melo said the following on 2008-3-28 10:07:
> Em Fri, Mar 28, 2008 at 09:52:22AM +0800, Gui Jianfeng escreveu:
>> Vlad,
>> There is an useless parameter in sctp_cmd_hb_timer_update,
>> remove it.
>>
>> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
>> ---
>>  net/sctp/sm_sideeffect.c |    3 +--
>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
>> index 28eb38e..5daeab5 100644
>> --- a/net/sctp/sm_sideeffect.c
>> +++ b/net/sctp/sm_sideeffect.c
>> @@ -593,7 +593,6 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
>>  
>>  /* Helper function to update the heartbeat timer. */
>>  static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
>> -				     struct sctp_association *asoc,
>>  				     struct sctp_transport *t)
>>  {
>>  	/* Update the heartbeat timer.  */
>> @@ -1457,7 +1456,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>>  
>>  		case SCTP_CMD_HB_TIMER_UPDATE:
>>  			t = cmd->obj.transport;
>> -			sctp_cmd_hb_timer_update(commands, asoc, t);
>> +			sctp_cmd_hb_timer_update(commands, t);
>>  			break;
> 
> you mean it was not compiling before?
> 

Compiler can not find whether a parameter of function is used.

--
WCN

