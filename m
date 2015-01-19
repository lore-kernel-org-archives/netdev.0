From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: stop sending PTB packets for MTU < 1280
Date: Mon, 19 Jan 2015 14:50:58 -0500 (EST)
Message-ID: <20150119.145058.954790496532942109.davem@davemloft.net>
References: <1421357665-2804-1-git-send-email-hagen@jauu.net>
	<1421675722.32277.3.camel@stressinduktion.org>
	<CAPh34mc3T7W81J_NjMkHvQpjad1gTM3j99gnX8x8jnKvh2TBDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, fgont@si6networks.com
To: hagen@jauu.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAPh34mc3T7W81J_NjMkHvQpjad1gTM3j99gnX8x8jnKvh2TBDg@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Mon, 19 Jan 2015 15:00:21 +0100

> On 19 January 2015 at 14:55, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>
>> I think this is the correct way forward on how to deal with atomic
>> fragments.
>>
>> Hagen, do you submit patches to remove dst_allfrag/RTAX_FEATURE_ALLFRAG,
>> IPCORK_ALLFRAG, etc. for net-next, too?
> 
> Yes, patch sits already in the pipe. I wanted to wait for davem's pull.

It's one thing to change policy about how we might or might not
automatically set this bit in the kernel, but at a minimum you cannot
just remove RTAX_FEATURE_ALLFRAG, it's in a userspace header and
you'll break application builds.

Second of all, there is absolutely no reason to prevent the user from
setting this bit.  If someone wants to set RTAX_FEATURE_ALLFRAG on a
route on their own system, that is their business.
