From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: init_timer_deferrable conversion
Date: Mon, 17 Dec 2007 09:00:00 -0800
Message-ID: <20071217090000.64499fba@deepthought>
References: <Pine.LNX.4.64.0712162149220.4622@mini.warudkars.net>
	<20071217095504.b02241ee.dada1@cosmosbay.com>
	<20071217152943.10470215.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "parag.warudkar@gmail.com" <parag.warudkar@gmail.com>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754741AbXLQRBq@vger.kernel.org>
In-Reply-To: <20071217152943.10470215.dada1@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Dec 2007 15:29:43 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> On Mon, 17 Dec 2007 09:55:04 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> > On Sun, 16 Dec 2007 22:00:23 -0500 (EST)
> > Parag Warudkar <parag.warudkar@gmail.com> wrote:
> > 
> > > In my quest to get the wake-ups from idle per second down to bare minimum, 
> > > I noticed 3 places in the kernel that could benefit from 
> > > using init_timer_deferrable() instead of init_timer() -
> > > 
> > > a) drivers/net/sky2.c - watchdog_timer. This was showing up high on 
> > > Powertop's list of things that cause routine wakeups from idle. After 
> > > converting to init_timer_deferrable() the wakeups went down and this one 
> > > no longer shows up in powertop's list. 25% reduction.

This surprises me because it is a 1 hz timer and uses round_jiffies() in
the current kernel.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
