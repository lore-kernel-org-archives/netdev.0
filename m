From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net] ipv6: stop sending PTB packets for MTU < 1280
Date: Mon, 19 Jan 2015 23:05:58 +0100
Message-ID: <CAPh34mc_5XPqC5_Xdx3gZScfnqtZC7b9JPGp4FfWVh+PvSfb3w@mail.gmail.com>
References: <1421357665-2804-1-git-send-email-hagen@jauu.net>
	<1421675722.32277.3.camel@stressinduktion.org>
	<CAPh34mc3T7W81J_NjMkHvQpjad1gTM3j99gnX8x8jnKvh2TBDg@mail.gmail.com>
	<20150119.145058.954790496532942109.davem@davemloft.net>
	<1421697951.13047.9.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org,
	Fernando Gont <fgont@si6networks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1421697951.13047.9.camel@stressinduktion.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19 January 2015 at 21:05, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:

> Oh yes, although we never exposed an ip route knob for that, it is still
> possible users did set manually, so we cannot get rid of that, agreed.

I thought about that, sure but come to the conclusion that the code
cleanup outweigh an potential user somewhere in space (well, the use
case is broken and should be fixed). Additionally, I left the
RTAX_FEATURE_ALLFRAG (as mentioned) and removed all related
functionality - no visible API change (except no-op behavior).

Davem, I will sent the patch anyway. Feel free to accept/ignore.

Hagen
