From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 10:46:58 -0400 (EDT)
Message-ID: <20170426.104658.547156121898948265.davem@davemloft.net>
References: <20170426110241.GA28251@vergenet.net>
        <2e09d117-60f9-97ed-9f63-c94130ddbb0c@mojatatu.com>
        <20170426130506.GF1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, simon.horman@netronome.com,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55984 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S3001389AbdDZOrA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 10:47:00 -0400
In-Reply-To: <20170426130506.GF1867@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 26 Apr 2017 15:05:06 +0200

> Wed, Apr 26, 2017 at 02:46:22PM CEST, jhs@mojatatu.com wrote:
>>On 17-04-26 07:02 AM, Simon Horman wrote:
>>> On Tue, Apr 25, 2017 at 06:04:45PM +0200, Jiri Pirko wrote:
>>[..]
>>
>>> > So fix iproute2. It is always first kernel, then iproute2.
>>> 
>>> Perhaps I am missing the point or somehow misguided but I would expect that
>>> if the UAPI uses BIT() it also provides BIT().
>>
>>There is a user of BIT() already in iproute2 (devlink). We can move
>>the code to be more generally available for other iproute2 users.
>>Then this UAPI change makes use of it.
> 
> Should be part of UAPI as well
> I see that include/uapi/rdma/vmw_pvrdma-abi.h is using BIT macro.
> I don't see BIT macro defined in UAPI (I thought it is). So either
> define it there (not sure where) or just use "<<"

"BIT" is a pretty crazy small simple name to pollute into the global
namespace, IMHO.
