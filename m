From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v4] ovs: limit ovs recursions in ovs_execute_actions
 to not corrupt stack
Date: Mon, 18 Jan 2016 17:58:28 +0100
Message-ID: <569D19B4.5010707@stressinduktion.org>
References: <CAOrHB_BCZRG8NinFintTcaRd0MBsYPt-hAH9LG+6uNwOa0GQaA@mail.gmail.com>
 <20160117.192628.1780434341967114696.davem@davemloft.net>
 <569CCAAC.6060906@stressinduktion.org>
 <20160118.115030.221096335100780663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org,
	simon.horman@netronome.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45631 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755749AbcARQ6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 11:58:30 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id BAF2120A3E
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 11:58:29 -0500 (EST)
In-Reply-To: <20160118.115030.221096335100780663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.01.2016 17:50, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 18 Jan 2016 12:21:16 +0100
>
>> I don't think that -rt kernels are important for openvswitch right
>> now, so this is just a safe guard.
>
> Hannes, whilst I don't want to explicitly make things harder for the -rt
> folks, I don't think it's appropriate to put unnecessary preemtption
> disables into the main kernel like this.
>
> Someone reading the code as-is will say this is superfluous and (correctly)
> submit a patch to remove the preemption disables.
>
> Please remove this from your patch, someone can deal with this in the
> -rt kernel as needed.

I am fine with that. Actually I had the same feeling, but seeing such a 
patch being discussed and explicitly ignoring this issue in another part 
made me feel a little bit bad.

Will resend in some seconds.

Bye,
Hannes
