From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Tue, 23 Sep 2008 12:06:44 +0000
Message-ID: <20080923120644.GD4692@ff.dom.local>
References: <48D7385D.40107@bigtelecom.ru> <20080922065339.GA4399@ff.dom.local> <48D76813.9000603@bigtelecom.ru> <20080922112452.GB5314@ff.dom.local> <48D79709.80400@bigtelecom.ru> <20080922172349.GA2545@ami.dom.local> <48D89E0C.9040407@bigtelecom.ru> <20080923092504.GB4692@ff.dom.local> <48D8C695.2020302@bigtelecom.ru> <20080923115708.GC4692@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:64504 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbYIWMGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 08:06:51 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1711430fgg.17
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 05:06:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080923115708.GC4692@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 11:57:08AM +0000, Jarek Poplawski wrote:
> On Tue, Sep 23, 2008 at 02:36:05PM +0400, Badalian Vyacheslav wrote:
> > 
> > > 2) Non-default qdiscs (any qdiscs added with tc): there is only one
> > > root qdisc (with its tree) as before, dequeued to all tx queues (if
> > > available). Since there is only one qdisc lock, and additional flag
> > > preventing other processes to run the qdisc at the same time, there
> > > is not so much advantage of SMP, except on tx locking. All previous
> > > tc configs should work without changes (except sch_prio and sch_rr
> > > used for multiqueuing, replaced by sch_multiq and act_skbedit now).
> > > Probably in some cases adding sch_multiq to a tree for separating
> > > qdisc queues per tx queues could be useful.
...
> > 2. I can locate module like sch_multiq at last 2.6.27-rc tree and not
> > have information of it in google... I need to know only one thing - what
> > params for hashing was planned for it?
> 
> sch_multiq doesn't use any params for hashing now - it uses mapping
> in packets to separate them to different bands/queues. So, by default
> it'll respect common hashing. You can change this using any filter with
> act_skbedit (Documentation/networking/multiqueue.txt).

OOPS!!! This 2.6.27-rc is so ...old I forgot the sch_multiq and
act_skbedit are only for the -next!

I'm very sorry for misleading!!!
Jarek P.
