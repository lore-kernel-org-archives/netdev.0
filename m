From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ipv4: warnings on sk_wmem_queued
Date: Wed, 4 Sep 2013 00:21:50 +0000
Message-ID: <20130904002150.GA14033@dcvr.yhbt.net>
References: <20130830195638.GA27393@dcvr.yhbt.net>
 <alpine.DEB.2.02.1308311229280.3532@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1308311229280.3532@dtop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dormando <dormando@rydia.net> wrote:
> > I noticed these warnings on stock 3.10.9 running stress tests on
> > cmogstored.git (git://bogomips.org/cmogstored.git) doing standard
> > HTTP server stuff between lo and tmpfs:
> >
> [...]
> > I was going to reboot into 3.10.10 before I looked at dmesg.  These
> > warnings happened after ~8 hours of stress tests, and those stress tests
> > are still running.
> 
> I had a kernel panic this morning on a production machine, also running
> 3.10.9. I only got a small part of the end of the trace, but it matches:

I haven't managed to hit any kernel panic nor my original warning again
after all these days of constant 20+ GB/s lo traffic.  I'll finally
reboot into 3.10.10 now.  dmesg has been completely quiet since the warning
and the machine is still running well.

> (also: hi Eric!)

Hi dormando!
