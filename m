From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: sky2 panic in 2.6.32.1 under load
Date: Thu, 24 Dec 2009 11:28:57 -0500
Message-ID: <200912241128.57599.dhazelton@enter.net>
References: <4B300A2A.8040305@gmail.com> <20091223225855.4a7d00af.akpm@linux-foundation.org> <4B3390EC.5060408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Berck Nash <flyboy@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755575AbZLXQ3K@vger.kernel.org>
In-Reply-To: <4B3390EC.5060408@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 December 2009 11:03:56 am Berck Nash wrote:
> Andrew Morton wrote:
> > On Mon, 21 Dec 2009 16:52:10 -0700 "Berck E. Nash" <flyboy@gmail.com> 
wrote:
> >> Since 2.6.32, I've been getting kernel panics under heavy network load
> >> (bittorrent usage).
> >
> > Let's cc the right list and developer.
> >
> > This is a 2.6.31->2.6.32 regression?
> 
> I believe so.  Since it's intermittent and difficult to reproduce, it's
> possible (but unlikely) that I simply never triggered it under 2.6.31.

This is far from new. I have seen this under 2.6.27 when at least one botnet 
has been pointed at a server of mine and told to gain access. It has happened 
four times in the last six to eight months - and I have no easy way to capture 
the logs. But the oops that was posted looks very, very similar to what I've 
seen.

It's always an allocation error in the transmit path that leads to the panic. 
Because this is a production machine that I do not have a way to take down and 
do testing with I've not reported the problem before.

DRH
