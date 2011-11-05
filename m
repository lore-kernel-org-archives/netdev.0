From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC 00/11] HFSC patches
Date: Sat, 05 Nov 2011 04:48:00 +0100
Message-ID: <4EB4B1F0.20404@trash.net>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61819 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab1KED4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 23:56:08 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.11.2011 03:32, Michal Soltys wrote:
> Those are most of the patches I've been sitting on for a while. For the most
> part they are either small corrections or simplifications (marked with s) - but
> there are also some new things (marked with !), the most interesting being #8
> probably.
> 
> All changes are richly commented in respective commit messages. I've been using
> them for a while - so unless I missed some subtlety, all should be fine.

Thanks Michal. It has been quite a while since I've last looked
at this and this is complicated stuff, please give me a few days
to review your patches.

> Apart from these, there's still one subtle thing to do w.r.t. cl_cvtmin (during
> init_vf(), as this value is lagged relatively to the situation at the time of
> enqueue).
> 
> On a side note, I was thinking about something like hfsc-strict or so - where
> [uplink] interface could be upperlimited on hfsc qdisc level, but all the class
> upperlimit would be otherwise gone. Not sure if anyone would be even interested
> in something like that at all.

So classes would just use link-sharing curves? That's
already possible, so I probably don't get your idea.
