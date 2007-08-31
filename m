From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 13:28:15 +0200
Message-ID: <20070831112815.GB3108@ff.dom.local>
References: <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F273.5010401@bigtelecom.ru> <46D7F4AB.10009@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:46381 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755051AbXHaL0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 07:26:51 -0400
Content-Disposition: inline
In-Reply-To: <46D7F4AB.10009@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 02:59:55PM +0400, Badalian Vyacheslav wrote:
> May be this bug eq "[PATCH] [NET_SCHED] sch_prio.c: remove duplicate 
> call of tc_classify()"?
> 
> >I get kernel panic on 2.6.23-rc4-git2
> >This is netconsole log!
> ...
> 

So, it looks like you have found a really new (unknown) HTB bug,
congratulations! We've only to find where is it hidden now...

I don't think tc_classify could do such a harm to HTB, and can't
see similar double calling as in sch_prio.

Jarek P.
