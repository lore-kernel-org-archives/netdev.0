From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Thu, 30 Aug 2007 14:37:51 +0200
Message-ID: <20070830123751.GA2778@ff.dom.local>
References: <46D53D9C.5070204@bigtelecom.ru> <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local> <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:52872 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756442AbXH3Mga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 08:36:30 -0400
Content-Disposition: inline
In-Reply-To: <46D68937.7030305@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 01:09:11PM +0400, Badalian Vyacheslav wrote:
> Jarek Poplawski ??????????:
...
> >On the other hand disabling local interrupts shouldn't be enough here,
> >so it's really strange... Did you get this remotely? Are you sure LOC
> >only? (Anyway this 2.6.23-rc4 should be interesting.)
...
> Only LOC changes... icmp answer = 50-70ms... after 1-2 hours traffic 
> level is down and SI on CPU0 and CPU2 change to above 50%. ksoftirqd 
> free CPU usage. I have this bug 3-4 times in week. If you need info what 
> i can see only in bug still processing - i may try get this info for you.

Any additional info could be helpful. I'm not sure if all these
computers do similar htb processing, or it's another problem?
As I've written before htb before 2.6.23-rc1 has a problem with
timer lockup during qdisc_destroy, so softirqs would be hit.
If it's htb's fault 2.6.23-rc4 or my testing patch should help.

I try to find in htb code another weak points. BTW, if during
such lockups any processes are killed 'by hand' etc., without
restarting the whole system, please let us know.

> maybe help:
> 
> 1U server INTEL, mb se7501w2
> 
> nat-new ~ # lspci

lspci -v (or -vv should be more usable - but with dmesg at least)

Jarek P.

