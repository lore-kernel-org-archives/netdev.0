From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: Weird NET_RX softirq behavior
Date: Fri, 8 Aug 2014 14:55:33 +0800
Message-ID: <20140808145533.5675e695@xhacker>
References: <20140807171050.77819b10@xhacker>
	<20140807181813.37b73927513266381d55ad0d@qrator.net>
	<20140808103734.677bff7e@xhacker>
	<1407476878.3604.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Popov <ixaphire@qrator.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:7730 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752547AbaHHG5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 02:57:47 -0400
In-Reply-To: <1407476878.3604.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Aug 2014 22:47:58 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Fri, 2014-08-08 at 10:37 +0800, Jisheng Zhang wrote:
> > nd and recive 7 packets so far, about 1400bytes. Seems small
> > comparing with the CPU1 and CPU2 NET_RX softirq numbers, right?
> > 
> > Any other possible case?
> 
> Multicast loop. Check dev_loopback_xmit() and its callers.
> 
> 

That's it! This make sense

I didn't see any NET_RX on CPU1,2,3 if I disabled mulitcast

Thanks very much.
