From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 09:31:37 -0400
Message-ID: <1243690297.3966.135.camel@dogo.mojatatu.com>
References: <1243604796.3966.21.camel@dogo.mojatatu.com>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	 <20090530114506.GA3166@ami.dom.local>
	 <1243684594.3966.89.camel@dogo.mojatatu.com>
	 <20090530120750.GB3166@ami.dom.local>
	 <1243686683.3966.117.camel@dogo.mojatatu.com>
	 <20090530124554.GC3166@ami.dom.local>
	 <1243688628.3966.126.camel@dogo.mojatatu.com>
	 <20090530132047.GD3166@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:29747 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754631AbZE3Ncf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 09:32:35 -0400
Received: by qw-out-2122.google.com with SMTP id 5so4384094qwd.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 06:32:36 -0700 (PDT)
In-Reply-To: <20090530132047.GD3166@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-30 at 15:20 +0200, Jarek Poplawski wrote:

> Yes it oopses in cls_cgroup_classify(). Here is the first report:
> http://permalink.gmane.org/gmane.linux.network/128593
> 

Oopsing in classify is after the fact though. It should not have been
linked to begin with (because wrong config was passed from user space).
As far as cls_group is concerned that is an illegitimate config - thats
why it failed it.

What were you suggesting to change in cls_group to avoid this oops?

> We add/link unconfigured tp, but it could be destroyed later, so I
> wouldn't call this a memory leak.

Indeed - call it "We add/link unconfigured tp".

Anyways, a nice sun just came out over here and i am off to run 
some chores. If you respond you will hear from me in a few hours.

cheers,
jamal

