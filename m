From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 15:20:47 +0200
Message-ID: <20090530132047.GD3166@ami.dom.local>
References: <1243604796.3966.21.camel@dogo.mojatatu.com> <1243605269.3966.28.camel@dogo.mojatatu.com> <20090529225929.GD2753@ami.dom.local> <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com> <20090530114506.GA3166@ami.dom.local> <1243684594.3966.89.camel@dogo.mojatatu.com> <20090530120750.GB3166@ami.dom.local> <1243686683.3966.117.camel@dogo.mojatatu.com> <20090530124554.GC3166@ami.dom.local> <1243688628.3966.126.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:44309 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbZE3NUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 09:20:54 -0400
Received: by bwz22 with SMTP id 22so6627339bwz.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 06:20:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1243688628.3966.126.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2009 at 09:03:48AM -0400, jamal wrote:
> On Sat, 2009-05-30 at 14:45 +0200, Jarek Poplawski wrote:
> > On Sat, May 30, 2009 at 08:31:23AM -0400, jamal wrote:
...
> > > The ops is caused by the code fixed in the patch - did i miss something?
> > 
> > IMHO it could be fixed "old way" in cls_group code too.
> 
> Is the code oopsing in cls_group? It didnt seem to be so to me, and
> yes cls_group is quarky in its practise (but thats a separate issue)
> and even if it did oops in cls_group - this change above is a memory
> leak and needs to be fixed in -stable. 

Yes it oopses in cls_cgroup_classify(). Here is the first report:
http://permalink.gmane.org/gmane.linux.network/128593

We add/link unconfigured tp, but it could be destroyed later, so I
wouldn't call this a memory leak.

Cheers,
Jarek P.
