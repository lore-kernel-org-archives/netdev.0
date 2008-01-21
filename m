From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24 regression: reference count leak in PPPoE
Date: Sun, 20 Jan 2008 16:08:33 -0800 (PST)
Message-ID: <20080120.160833.166998420.davem@davemloft.net>
References: <200801202053.30386.ak@suse.de>
	<20080120200109.GA31876@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org
To: mingo@elte.hu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756940AbYAUAIm@vger.kernel.org>
In-Reply-To: <20080120200109.GA31876@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 20 Jan 2008 21:01:09 +0100

> 
> * Andi Kleen <ak@suse.de> wrote:
> 
> > My workstation running 2.6.24-rc8 just hung during shutdown with an 
> > endless (or rather I didn't wait more than a few minutes) loop of
> > 
> > unregister_netdev: waiting for ppp-device to become free. Usage count 
> > = 1
> > 
> > ppp-device was an active PPPoE device.
> > 
> > No more information currently.
> 
> i've seen such problems (locked up box with endless loop of usage count 
> == 1) with pppoe in the past, and it seemed to be related to dynamic 
> IPs. (i saw that well before 2.6.24 - reported it once to davem)

No, this is a different bug Andi is seeing and it was
recently introduced:

	http://bugzilla.kernel.org/show_bug.cgi?id=9778
