From: Olaf Kirch <okir@suse.de>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Wed, 8 Nov 2006 23:10:28 +0100
Message-ID: <20061108221028.GA16889@suse.de>
References: <1162924354.10806.172.camel@localhost.localdomain> <1163001318.3138.346.camel@laptopd505.fenrus.org> <20061108162955.GA4364@suse.de> <1163011132.10806.189.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, davem@sunset.davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423798AbWKHWKp@vger.kernel.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <1163011132.10806.189.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 08, 2006 at 10:38:52AM -0800, Tim Chen wrote:
> The patch in question affects purely TCP and not the scheduler.  I don't

I know.

> think the scheduler has anything to do with the slowdown seen after
> the patch is applied.

In fixing performance issues, the most obvious explanation isn't always
the right one. It's quite possible you're right, sure.

What I'm saying though is that it doesn't rhyme with what I've seen of
Volanomark - we ran 2.6.16 on a 4p Intel box for instance and it didn't
come close to saturating a Gigabit pipe before it maxed out on CPU load.

> The total number of messages being exchanged around the chatrooms in 
> Volanomark remain unchanged.  But ACKS increase by 3.5 times and
> segments received increase by 38% from netstat.  

> So I think it is reasonable to conclude that the increase in TCP traffic
> reduce the bandwidth and throughput in Volanomark.

You could count the number of outbound packets dropped on the server.

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.
