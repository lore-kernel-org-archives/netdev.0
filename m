From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from
 tc_action_ops
Date: Fri, 13 Dec 2013 18:23:25 -0500 (EST)
Message-ID: <20131213.182325.2234215963739207753.davem@davemloft.net>
References: <52AB7ECB.30702@mojatatu.com>
	<CAM_iQpXBGouT+rj=QscwtiNCGdnNi=mJq4Df7xbkgygnMQEEMg@mail.gmail.com>
	<52AB87EB.6040508@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, David.Laight@aculab.com,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab3LMXX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 18:23:29 -0500
In-Reply-To: <52AB87EB.6040508@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 13 Dec 2013 17:19:23 -0500

> On 12/13/13 16:50, Cong Wang wrote:
> 
>> I must miss something here...
> 
> You are.
> This api is for use for additional stats other than the generic
> stats. It will export such extra stats to user space. There is nothing
> unusual here - if you look at qdiscs and classes you will see
> equivalent
> interfaces.
> It has been there for a decade. It has been used in the past and it
> may still be in use by other modules in the wild (even if i or you
> dont care about them). Please dont break things.

Jamal, nobody implements this interface, therefore these extra
stats are _NEVER_ provided.

This is the end of the discussion, when there are in-tree users
of this method you can add it back.

Userland will have no idea whether it is there or not, because
there is no way for it to tell one way or another.
