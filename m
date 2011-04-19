From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 0/8] sctp: some cleanup and tiny fix for
 add/del ip
Date: Tue, 19 Apr 2011 16:18:51 +0800
Message-ID: <4DAD456B.7020105@cn.fujitsu.com>
References: <4DAD18AB.3040401@cn.fujitsu.com> <4DAD438D.8040506@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50555 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752807Ab1DSISp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 04:18:45 -0400
In-Reply-To: <4DAD438D.8040506@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Hi Wei Yongjun,
>
> do you plan to send other patches, like "sctp: make sctp over IPv6 wo=
rk with IPsec.", too?

Yes, I am doing this work now. And will commit those patch after backpo=
rt
to net-next-2.6 tree and testing.

>
>
> Regards,
> Nicolas
>
> Le 19/04/2011 07:07, Wei Yongjun a =C3=A9crit :
>> Series of 8 patches against net-next-2.6, include some cleanup
>> and tiny fix for add/del ip, which have been waiting on vlad's
>> lksctp-dev tree for long times.
>>
>> Shan Wei (5):
>>        sctp: delete unused macro definition of sctp_chunk_is_control
>>        sctp: fix the comment of sctp_sf_violation_paramlen()
>>        sctp: use common head of addr parameter to access member in a=
ddr-unrelated code
>>        sctp: kill abandoned SCTP_CMD_TRANSMIT command
>>        sctp: use memdup_user to copy data from userspace
>>
>> Vlad Yasevich (3):
>>        sctp: teach CACC algorithm about removed transports
>>        sctp: Allow bindx_del to accept 0 port.
>>        sctp: Release all routes when processing acks ADD_IP or DEL_I=
P
>>
>>   include/net/sctp/command.h   |    1 -
>>   include/net/sctp/constants.h |    1 -
>>   net/sctp/input.c             |    2 +-
>>   net/sctp/outqueue.c          |   11 ++++++++---
>>   net/sctp/sm_make_chunk.c     |   18 +++++++-----------
>>   net/sctp/sm_sideeffect.c     |    6 ------
>>   net/sctp/sm_statefuns.c      |    5 +++--
>>   net/sctp/socket.c            |   28 +++++++++++-----------------
>>   8 files changed, 30 insertions(+), 42 deletions(-)
>>
>>
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp=
" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
