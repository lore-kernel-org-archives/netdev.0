From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 19:08:53 -0400
Message-ID: <1243724933.3966.158.camel@dogo.mojatatu.com>
References: <20090529225929.GD2753@ami.dom.local>
	 <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	 <20090530114506.GA3166@ami.dom.local>
	 <1243684594.3966.89.camel@dogo.mojatatu.com>
	 <20090530120750.GB3166@ami.dom.local>
	 <1243686683.3966.117.camel@dogo.mojatatu.com>
	 <20090530124554.GC3166@ami.dom.local>
	 <1243688628.3966.126.camel@dogo.mojatatu.com>
	 <20090530132047.GD3166@ami.dom.local>
	 <1243690297.3966.135.camel@dogo.mojatatu.com>
	 <20090530140006.GE3166@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:46866 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbZE3XJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 19:09:50 -0400
Received: by qw-out-2122.google.com with SMTP id 5so4523769qwd.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 16:09:52 -0700 (PDT)
In-Reply-To: <20090530140006.GE3166@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-30 at 16:00 +0200, Jarek Poplawski wrote:
> On Sat, May 30, 2009 at 09:31:37AM -0400, jamal wrote:
> > What were you suggesting to change in cls_group to avoid this oops?
> 
> I think checking the head (tp->root) for NULL like in cls_fw or
> cls_route should work.

IMHO that is a workaround for the tp linking bug
[IOW, there is no need to check for tp->root == NULL (in the fast path)
if such an illegal tp was never linked to begin with (on the slow
path)].

So those classifiers you point to need to be fixed afterwards (but 
not -stable material).
My thinking of fixing them to do proper init/get as well later.

> Anyway, it's worked for other classifiers like this for some time...

Would you agree that it is/was a bandaid?
Or maybe you have some other fear that this may break something else and
prefer the workaround instead?

cheers,
jamal

