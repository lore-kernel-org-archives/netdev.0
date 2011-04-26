From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 4/7] sctp: remove useless arguments from
 get_saddr() call
Date: Tue, 26 Apr 2011 16:06:17 +0800
Message-ID: <4DB67CF9.1050508@cn.fujitsu.com>
References: <4DB63F85.2090609@cn.fujitsu.com>	<4DB6405B.2060200@cn.fujitsu.com>	<20110426.001227.112589346.davem@davemloft.net> <20110426.002020.48493363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60456 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750805Ab1DZIGc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 04:06:32 -0400
In-Reply-To: <20110426.002020.48493363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: David Miller <davem@davemloft.net>
> Date: Tue, 26 Apr 2011 00:12:27 -0700 (PDT)
>
>> I really get grumpy when I have to fix up stuff like this:
>>
>> net/sctp/ipv6.c: In function =A1sctp_v6_get_saddr=A2:
>> net/sctp/ipv6.c:382: warning: unused variable =A1daddr=A2
> Now I'm even more grumpy, if I only apply the first 3 patches:
>
> net/sctp/ipv6.c: In function =A1sctp_v6_dst_lookup=A2:
> net/sctp/ipv6.c:259: warning: assignment makes integer from pointer w=
ithout a cast
>
> it goes away later but you're not testing the intermediate steps
> of your SCTP patch backports and as a result you are going to
> break bisecting.
>
> I'm reverting this patch series, fix this up and actually test
> the intermediate builds and functionality before resubmission.
Hi David

 Sorry for sending those garbage and wasted your time so much,
I will fix those up and do all of the test before resubmit
those patch to you.


