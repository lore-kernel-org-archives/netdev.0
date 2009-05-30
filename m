From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 16:00:06 +0200
Message-ID: <20090530140006.GE3166@ami.dom.local>
References: <20090529225929.GD2753@ami.dom.local> <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com> <20090530114506.GA3166@ami.dom.local> <1243684594.3966.89.camel@dogo.mojatatu.com> <20090530120750.GB3166@ami.dom.local> <1243686683.3966.117.camel@dogo.mojatatu.com> <20090530124554.GC3166@ami.dom.local> <1243688628.3966.126.camel@dogo.mojatatu.com> <20090530132047.GD3166@ami.dom.local> <1243690297.3966.135.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:55345 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767AbZE3OBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 10:01:55 -0400
Received: by bwz22 with SMTP id 22so6640661bwz.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 07:01:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1243690297.3966.135.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2009 at 09:31:37AM -0400, jamal wrote:
> On Sat, 2009-05-30 at 15:20 +0200, Jarek Poplawski wrote:
> 
> > Yes it oopses in cls_cgroup_classify(). Here is the first report:
> > http://permalink.gmane.org/gmane.linux.network/128593
> > 
> 
> Oopsing in classify is after the fact though. It should not have been
> linked to begin with (because wrong config was passed from user space).
> As far as cls_group is concerned that is an illegitimate config - thats
> why it failed it.
> 
> What were you suggesting to change in cls_group to avoid this oops?

I think checking the head (tp->root) for NULL like in cls_fw or
cls_route should work.

> 
> > We add/link unconfigured tp, but it could be destroyed later, so I
> > wouldn't call this a memory leak.
> 
> Indeed - call it "We add/link unconfigured tp".

Anyway, it's worked for other classifiers like this for some time...

> Anyways, a nice sun just came out over here and i am off to run 
> some chores. If you respond you will hear from me in a few hours.

Sure, we could probably stop this till Monday.

Cheers,
Jarek P.
