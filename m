From: denys@visp.net.lb
Subject: Re: NMI lockup, 2.6.26 release
Date: Wed, 23 Jul 2008 00:45:30 +0300
Message-ID: <200807230045.30891.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <200807222346.36284.denys@visp.net.lb> <20080722213603.GA3026@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:50232 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbYGVVpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:45:42 -0400
In-Reply-To: <20080722213603.GA3026@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, i cannot see similar or not, only guess. Machine is crashing after few days, even without neconsole. Sometimes rebooting, sometimes not. 
So sometimes i am getting call at middle of night and running to power switch to reboot PC. I cannot check screen, it is in unreachable for me area.
This bug probably is since 2.6.23 even...

I will engage kexec with panic kernel just to be more safe, since it is not always rebooting over panic sysctl.
As i see in sources path to panic kexec kernel is much shorter... 


On Wednesday 23 July 2008, Jarek Poplawski wrote:
> On Tue, Jul 22, 2008 at 11:46:36PM +0300, denys@visp.net.lb wrote:
> > First patch - probably not related. Netconsole is on e100.
> > Second patch looks reasonable, because there is external interface (it is router) and e1000e there, with enabled TSO. Maybe some scanning tools doing connect to SSH and... BOOM.. i will try to patch it, thanks a lot!
> 
> On the other hand, it seems the corruption of skbs fixed by this
> second patch should probably show in some other places...
> 
> I wonder if you tried to run this without netconsole (or maybe
> netconsole on another dev/driver) or without this NMI watchdog,
> and similar lockups still happened?
> 
> Jarek P.
> 
> > 
> > On Tuesday 22 July 2008, Jarek Poplawski wrote:
> > > Jarek Poplawski wrote, On 07/22/2008 10:13 PM:
> > > 
> > > > denys@visp.net.lb wrote, On 07/22/2008 08:42 PM:
> > > > 
> > > >> workload: ifb shapers, HTB, nat, 1 e1000, 3 e100 (heavily used only two e100)
> > > >>
> > > > 
> > > > 
> > > > Maybe it's unconnected but I'd recommend to try this fresh patch for
> > > > possible problems with e1000e vs. netconsole:
> > > > 
> > > > http://permalink.gmane.org/gmane.linux.network/100581
> > >  
> > > 
> > > ...and if you have TSO enabled, here is another "maybe unconnected"
> > > recommendation:
> > > 
> > > http://permalink.gmane.org/gmane.linux.network/99585
> > > 
> > > Jarek P.
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > 
> > 
> 


