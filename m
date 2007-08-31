From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 10:49:33 +0200
Message-ID: <20070831084932.GB1772@ff.dom.local>
References: <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:54083 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754675AbXHaIsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 04:48:09 -0400
Content-Disposition: inline
In-Reply-To: <46D7D072.5060508@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 12:25:22PM +0400, Badalian Vyacheslav wrote:
> i not have testing mashine.
> we have 2 mashine and dynamic routing. if 1 mashine down - all traffic 
> go to second mashine.
> I can test is on this mashines but i need that testing mashine will 
> reboot on kernel panic (sysctl message). No freezes =)
> 
> Ok. i try 2.6.23-rc4.
> 
> >On Fri, Aug 31, 2007 at 11:04:21AM +0400, Badalian Vyacheslav wrote:
> >  
> >>I try you patch. Also i try add more debug options to kernel. I catch 
> >>(BUG: spinlock lockup on CPU#3, tc/6403, f742e200)

BTW, I think after this BUG could be something more about other CPUs.
Could you check this?

Jarek P.

PS: If it's possible try to not cut too much: if there is something
confidential mask this with some XXX or mark the cut with... There
could matter what else is run at the same time (including other
driver's warnings). If you think it's too much for a list you can
send it to me only.
