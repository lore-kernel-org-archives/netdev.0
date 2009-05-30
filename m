From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 19:34:52 -0400
Message-ID: <1243726492.3966.178.camel@dogo.mojatatu.com>
References: <20090529225929.GD2753@ami.dom.local>
	 <20090530114506.GA3166@ami.dom.local>
	 <1243684594.3966.89.camel@dogo.mojatatu.com>
	 <20090530120750.GB3166@ami.dom.local>
	 <1243686683.3966.117.camel@dogo.mojatatu.com>
	 <20090530124554.GC3166@ami.dom.local>
	 <1243688628.3966.126.camel@dogo.mojatatu.com>
	 <20090530132047.GD3166@ami.dom.local>
	 <1243690297.3966.135.camel@dogo.mojatatu.com>
	 <20090530140006.GE3166@ami.dom.local>
	 <b10243b50905301538o2716855ag21fbc95b37c8da22@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Minoru Usui <mi.usui@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:36953 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbZE3Xfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 19:35:50 -0400
Received: by qw-out-2122.google.com with SMTP id 5so4529827qwd.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 16:35:51 -0700 (PDT)
In-Reply-To: <b10243b50905301538o2716855ag21fbc95b37c8da22@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-05-31 at 07:38 +0900, Minoru Usui wrote:

> I agree.
> I think cls_cgroup should check head(tp->root) whether NULL or not
> like other classifiers, too.
> 

I dont think this is necessary if the adding/linking unconfigured tp
doesnt happen on failed config.

cheers,
jamal

