From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 14:59:17 +0200
Message-ID: <20070831125917.GC3108@ff.dom.local>
References: <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F1FF.1000101@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:43304 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964979AbXHaM5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 08:57:55 -0400
Content-Disposition: inline
In-Reply-To: <46D7F1FF.1000101@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 02:48:31PM +0400, Badalian Vyacheslav wrote:
...
> I can only see that say netconsole. If i look to monitor i look last 
> lines. last line is "====...". Scrolling not work
> netconsole run as module and start after system do full load. Then 
> netconsole is up - i run generator of tc scripts.

It would be interesting to know if this bug did ever happen without
netconsole, or, if it wasn't tested this way, if it's possible to
do such a test (not necessarily today)?

> >BTW, -git versions are usually more risky than -rc. And, maybe, let
> >this 2.6.18 better stay away from this testing...
> >  
> I look changes between 2.6.23-rc4 and 2.6.23-rc4-git2 and think that 
> paches look good and no do any critical things =)
> 
> Now i do many script runs to simulate bug. if i get it on 2.6.23-rc4 - i 
> post it here. 2.6.23-rc4 not have htb_timer function.

I'll not be able to assist you until monday (but I'll try to look
into the code and maybe to prepare some new patch - but it needs
a lot of checking to not add too much of this locking as well).

I think you can stay with a kernel whichever you like - I'm not sure
any config changes or even more debugging can change much, but maybe
I'm wrong. It looks to me like some locking is missing or interrupted.
If you are working weekends and find something new, don't wait: maybe
somebody else here could be interested too.
 
Cheers,
Jarek P. 
