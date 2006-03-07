From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: de2104x: interrupts before interrupt handler is registered
Date: Tue, 7 Mar 2006 05:16:20 +0000
Message-ID: <20060307051620.GB1244@deprecation.cyrius.com>
References: <20060305180757.GA22121@deprecation.cyrius.com> <20060305185948.GA24765@electric-eye.fr.zoreil.com> <20060306143512.GI23669@deprecation.cyrius.com> <20060306191706.GA6947@deprecation.cyrius.com> <20060306194821.GA15728@electric-eye.fr.zoreil.com> <20060306195953.GB10703@deprecation.cyrius.com> <20060306205406.GC15728@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750899AbWCGFQf@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060306205406.GC15728@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-03-06 21:54]:
> > By the way, I'm getting the following messages in dmesg:
> > eth0: tx err, status 0x7fffb002
> Tx underrun.
> Is there anything which could induce a noticeable load on the PCI bus ?

I was going to say "no" because I was simply copying some data via the
network.  However, it seems the situation is a bit more complicated
than this.  It seems that I only get these underruns using a specific
hard drive.  You see, the reason I'm rsyncing hundred of megabytes of
data across my LAN is because my laptop hard drive is dying, so I put
it in a PC as secondary master using an adapter.  Interestingly
enough, I don't get any Tx underruns when using a different disk.
Which is strange because at the moment the disk is working fine (it
sort of started dying but seems to behave right now), so I don't know
why it would change anything.  Maybe this makes sense to someone.

By the way, I only get underruns when I rsync from the PC to another
machine - not when I rsync from the other machine to the PC.
-- 
Martin Michlmayr
http://www.cyrius.com/
