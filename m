From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 17:19:23 -0500
Message-ID: <52AB87EB.6040508@mojatatu.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>	<1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>	<AE90C24D6B3A694183C094C60CF0A2F6026B7489@saturn3.aculab.com>	<CAM_iQpVgo+nxN3eTRg_F9u+-k4ML+D3ZqsrAEOeLZwtU6dOk3g@mail.gmail.com>	<52AB7BC6.9050503@mojatatu.com>	<CAM_iQpWq64+Ae-ZESxGxGMLeFE2tRJeBGF+6E0-w5Qer2zk+3g@mail.gmail.com>	<52AB7ECB.30702@mojatatu.com> <CAM_iQpXBGouT+rj=QscwtiNCGdnNi=mJq4Df7xbkgygnMQEEMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:65189 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab3LMWTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 17:19:30 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so3770107ieb.11
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 14:19:30 -0800 (PST)
In-Reply-To: <CAM_iQpXBGouT+rj=QscwtiNCGdnNi=mJq4Df7xbkgygnMQEEMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/13 16:50, Cong Wang wrote:

> I must miss something here...

You are.
This api is for use for additional stats other than the generic
stats. It will export such extra stats to user space. There is nothing
unusual here - if you look at qdiscs and classes you will see equivalent
interfaces.
It has been there for a decade. It has been used in the past and it
may still be in use by other modules in the wild (even if i or you
dont care about them). Please dont break things.

cheers,
jamal
