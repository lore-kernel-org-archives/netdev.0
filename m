From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: stop sending PTB packets for MTU < 1280
Date: Mon, 19 Jan 2015 21:05:51 +0100
Message-ID: <1421697951.13047.9.camel@stressinduktion.org>
References: <1421357665-2804-1-git-send-email-hagen@jauu.net>
	 <1421675722.32277.3.camel@stressinduktion.org>
	 <CAPh34mc3T7W81J_NjMkHvQpjad1gTM3j99gnX8x8jnKvh2TBDg@mail.gmail.com>
	 <20150119.145058.954790496532942109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, netdev@vger.kernel.org, stable@vger.kernel.org,
	fgont@si6networks.com
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150119.145058.954790496532942109.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mo, 2015-01-19 at 14:50 -0500, David Miller wrote:
> From: Hagen Paul Pfeifer <hagen@jauu.net>
> Date: Mon, 19 Jan 2015 15:00:21 +0100
> 
> > On 19 January 2015 at 14:55, Hannes Frederic Sowa
> > <hannes@stressinduktion.org> wrote:
> >> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >>
> >> I think this is the correct way forward on how to deal with atomic
> >> fragments.
> >>
> >> Hagen, do you submit patches to remove dst_allfrag/RTAX_FEATURE_ALLFRAG,
> >> IPCORK_ALLFRAG, etc. for net-next, too?
> > 
> > Yes, patch sits already in the pipe. I wanted to wait for davem's pull.
> 
> It's one thing to change policy about how we might or might not
> automatically set this bit in the kernel, but at a minimum you cannot
> just remove RTAX_FEATURE_ALLFRAG, it's in a userspace header and
> you'll break application builds.

Sure, the define would need to be left alone.

> Second of all, there is absolutely no reason to prevent the user from
> setting this bit.  If someone wants to set RTAX_FEATURE_ALLFRAG on a
> route on their own system, that is their business.

Oh yes, although we never exposed an ip route knob for that, it is still
possible users did set manually, so we cannot get rid of that, agreed.

Bye,
Hannes
