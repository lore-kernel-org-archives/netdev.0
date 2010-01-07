From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 7 Jan 2010 05:48:35 -0800
Message-ID: <20100107054835.18f0498e@s6510>
References: <20100107063545.GA6258@ff.dom.local>
	<20100107.000111.205787691.davem@davemloft.net>
	<20100107081501.GA7229@ff.dom.local>
	<20100107.001923.182599102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, mikem@ring3k.org, netdev@vger.kernel.org,
	flyboy@gmail.com, dhazelton@enter.net, mbreuer@majjas.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58686 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752235Ab0AGNtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 08:49:15 -0500
In-Reply-To: <20100107.001923.182599102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Jan 2010 00:19:23 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 7 Jan 2010 08:15:01 +0000
> 
> > Maybe right, but Mike's patch changelog above writes:
> > "Proposed fix for "sky2 panic under load" reported by Berck E. Nash.",
> > and maybe I missed something, but I can't find any report which
> > acknowledges this patch fixed this or down/suspending problem.
> 
> Certainly by my reading Mike's patch does in fact fix a race
> between device detach and the TX handler, so regardless of
> whether it fixes actual reported user problems it should
> at a minimum go into net-next-2.6
> 
> And that's _exactly_ what I did, and how I analyzed his work.


No objections, thanks.
