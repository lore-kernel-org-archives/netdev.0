From: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 3 Aug 2006 18:04:55 +0100
Message-ID: <200608031804.55292.s0348365@sms.ed.ac.uk>
References: <20060803075704.GC27835@thunk.org> <20060803163204.GB20603@thunk.org> <20060803094917.8280f5ff.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Theodore Tso <tytso@mit.edu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, mchan@broadcom.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964795AbWHCRFM@vger.kernel.org>
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060803094917.8280f5ff.rdunlap@xenotime.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 03 August 2006 17:49, Randy.Dunlap wrote:
[snip]
> > This only shows up with the real-time kernel where timer softirq's run
> > in their own processes, and a high priority process preempts the timer
> > softirq.  I don't really consider this a networking bug, or even
> > driver bug, although it does seem unfortunate that Broadcom hardware
> > locks up and goes unresponsive if the OS doesn't tickle it every tenth
> > of a second or so.  (Definitely a bad idea if the tg3 gets used on any
> > laptops, from a power usage perspective.)  But that seems like a
> > (lame) hardware bug, not a driver bug....
>
> Interesting.  On my Dell D610 notebook with tg3 and vpn,
> I have to ping a server on the vpn to keep it alive, otherwise
> it disappears soon and I have to restart the vpn.  Of course,
> this could just be the vpn or some other software problem
> instead of a tg3 problem.

Probably. I have an NC6000 with a tg3 and have never experienced link failure 
problems, even under -rt.

-- 
Cheers,
Alistair.

Final year Computer Science undergraduate.
1F2 55 South Clerk Street, Edinburgh, UK.
