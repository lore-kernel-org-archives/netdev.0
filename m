From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 19:13:14 -0400
Message-ID: <1243725194.3966.162.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	 <20090530114506.GA3166@ami.dom.local>
	 <1243684594.3966.89.camel@dogo.mojatatu.com>
	 <20090530120750.GB3166@ami.dom.local>
	 <1243686683.3966.117.camel@dogo.mojatatu.com>
	 <20090530124554.GC3166@ami.dom.local>
	 <1243688628.3966.126.camel@dogo.mojatatu.com>
	 <b10243b50905301522t42aafaffxbf5934388af3df93@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Minoru Usui <mi.usui@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:3852 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466AbZE3XOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 19:14:12 -0400
Received: by qw-out-2122.google.com with SMTP id 5so4524720qwd.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 16:14:13 -0700 (PDT)
In-Reply-To: <b10243b50905301522t42aafaffxbf5934388af3df93@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-05-31 at 07:22 +0900, Minoru Usui wrote:

> I'll do it after understanding above code.

Current patch has two places with:

+               if (n->nlmsg_type == RTM_NEWTFILTER &&
+                   (n->nlmsg_flags&NLM_F_CREATE)) {

The change (in the two spots) is:
+               if (n->nlmsg_type == RTM_NEWTFILTER &&
+                   (n->nlmsg_flags&(NLM_F_CREATE|NLM_F_EXCL))) {

cheers,
jamal

