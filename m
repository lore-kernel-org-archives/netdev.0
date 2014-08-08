From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: Weird NET_RX softirq behavior
Date: Fri, 8 Aug 2014 10:37:34 +0800
Message-ID: <20140808103734.677bff7e@xhacker>
References: <20140807171050.77819b10@xhacker>
	<20140807181813.37b73927513266381d55ad0d@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dmitry Popov <ixaphire@qrator.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807181813.37b73927513266381d55ad0d@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dmitry,

On Thu, 7 Aug 2014 07:18:13 -0700
Dmitry Popov <ixaphire@qrator.net> wrote:

> On Thu, 7 Aug 2014 17:10:50 +0800
> Jisheng Zhang <jszhang@marvell.com> wrote:
> 
> > 2. only one netdev in the system: eth0.
> 
> There should also be lo (loopback) at least.

Yep, I forget that ;)

> 
> > 4. But NET_RX seems abnormal
> > ~ # cat /proc/softirqs 
> >                     CPU0       CPU1       CPU2       CPU3       
> >       NET_RX:     445587        322        983          0
> > 
> > I'm expecting NET_RX under CPU1, 2, 3 should be zero. Any suggestions
> > about this abnormal behavior?
> 
> Do you have any loopback traffic? It could be handled by CPU1/2 explaining
> non-zero NET_RX counters.

Yes. lo only send and recive 7 packets so far, about 1400bytes. Seems small
comparing with the CPU1 and CPU2 NET_RX softirq numbers, right?

Any other possible case?

Thanks for your reply,
Jisheng
