From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Fri, 8 Jan 2010 23:02:28 +0100
Message-ID: <20100108220228.GB3078@del.dom.local>
References: <20100107180114.GB3088@del.dom.local>
 <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local>
 <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local>
 <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local>
 <4B475FF9.7000702@majjas.com>
 <20100108212923.GA3078@del.dom.local>
 <4B47A81B.5040601@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754193Ab0AHWCg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B47A81B.5040601@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 08, 2010 at 04:48:11PM -0500, Michael Breuer wrote:
> On 1/8/2010 4:29 PM, Jarek Poplawski wrote:
> >On Fri, Jan 08, 2010 at 11:40:25AM -0500, Michael Breuer wrote:
> >>On 1/8/2010 2:45 AM, Jarek Poplawski wrote:
> >>...
> >Berck Nash reported oopses during sky2 TX timeout recovery, which are
> >generally hardware/driver problems, and shouldn't be triggered by ip
> >level bugs, so it should be queried as a separate bug report.
> >
> My thought was that his crash was secondary to the netdev watchdog &
> subsequent reset that I saw.

Yes, the netdev watchdog which triggers on TX timeout.

Jarek P.
