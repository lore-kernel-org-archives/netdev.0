From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Tue, 22 Jul 2008 23:36:03 +0200
Message-ID: <20080722213603.GA3026@ami.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <48863F5A.9080104@gmail.com> <48864491.3010905@gmail.com> <200807222346.36284.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:51837 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbYGVVfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:35:15 -0400
Received: by mu-out-0910.google.com with SMTP id w8so1291413mue.1
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 14:35:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200807222346.36284.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 11:46:36PM +0300, denys@visp.net.lb wrote:
> First patch - probably not related. Netconsole is on e100.
> Second patch looks reasonable, because there is external interface (it is router) and e1000e there, with enabled TSO. Maybe some scanning tools doing connect to SSH and... BOOM.. i will try to patch it, thanks a lot!

On the other hand, it seems the corruption of skbs fixed by this
second patch should probably show in some other places...

I wonder if you tried to run this without netconsole (or maybe
netconsole on another dev/driver) or without this NMI watchdog,
and similar lockups still happened?

Jarek P.

> 
> On Tuesday 22 July 2008, Jarek Poplawski wrote:
> > Jarek Poplawski wrote, On 07/22/2008 10:13 PM:
> > 
> > > denys@visp.net.lb wrote, On 07/22/2008 08:42 PM:
> > > 
> > >> workload: ifb shapers, HTB, nat, 1 e1000, 3 e100 (heavily used only two e100)
> > >>
> > > 
> > > 
> > > Maybe it's unconnected but I'd recommend to try this fresh patch for
> > > possible problems with e1000e vs. netconsole:
> > > 
> > > http://permalink.gmane.org/gmane.linux.network/100581
> >  
> > 
> > ...and if you have TSO enabled, here is another "maybe unconnected"
> > recommendation:
> > 
> > http://permalink.gmane.org/gmane.linux.network/99585
> > 
> > Jarek P.
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> 
