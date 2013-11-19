From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 2/2] ipv6: use sk_v6_copy_addrs when memcpy struct ipv6_pinfo
Date: Tue, 19 Nov 2013 12:35:39 +0100
Message-ID: <528B4D0B.10204@redhat.com>
References: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>  <1384829247-8624-3-git-send-email-wangweidong1@huawei.com>  <20131119031408.GQ16541@order.stressinduktion.org>  <528ADBDD.9040209@huawei.com>  <1384833538.8604.83.camel@edumazet-glaptop2.roam.corp.google.com> <1384833653.8604.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangweidong <wangweidong1@huawei.com>, davem@davemloft.net,
	gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, vyasevich@gmail.com,
	nhorman@tuxdriver.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	dingtianhong@huawei.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618Ab3KSLgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 06:36:36 -0500
In-Reply-To: <1384833653.8604.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2013 05:00 AM, Eric Dumazet wrote:
> On Mon, 2013-11-18 at 19:58 -0800, Eric Dumazet wrote:
>
>> But sctp is not tcp ;)
>>
>> sctp_copy_sock() is doing some clever/partial copy of the socket, so
>> please fix it ;)
>>
>> No idea why it's not doing the normal copy of the socket.
>
> BTW, not doing the full copy means for example that SO_MAX_PACING_RATE
> is broken for SCTP.

Yep, indeed. Looking into it ...
