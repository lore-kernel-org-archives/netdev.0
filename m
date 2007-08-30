From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Thu, 30 Aug 2007 09:27:18 +0200
Message-ID: <20070830072718.GC1677@ff.dom.local>
References: <46D53D9C.5070204@bigtelecom.ru> <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local> <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:46463 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755395AbXH3HZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 03:25:57 -0400
Content-Disposition: inline
In-Reply-To: <20070830063110.GB1677@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 08:31:10AM +0200, Jarek Poplawski wrote:
> On Thu, Aug 30, 2007 at 12:16:32AM +0400, slavon@bigtelecom.ru wrote:
...
> > PS. And also have we have strange bug in another computer (2.6.22-r5).
> > Have computer XEON_CPUx2 (4 CPU)
> > 
> > after boot have CPU0 and CPU3 SI = ~50%
> > after some time CPU0 SI = 0% and ksoftirqd/2 process have 100% cpu usage!
> > nat-new ~ # cat /proc/interrupts
> >            CPU0       CPU1       CPU2       CPU3
> >   0:        403          0          0          0   IO-APIC-edge      timer
> ...
> > LOC:   89312505   89314019   89310139   89313972
> > ERR:          0
> > MIS:          0
> > 
> > changes only LOC interrupts!
> > 
> > Maybe its info intresting for you. =)
> 
> Yes. It seems something loops or breaks with disabled interrupts. If

On the other hand disabling local interrupts shouldn't be enough here,
so it's really strange... Did you get this remotely? Are you sure LOC
only? (Anyway this 2.6.23-rc4 should be interesting.)

Jarek P.
