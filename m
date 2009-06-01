From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 1 Jun 2009 06:06:38 +0000
Message-ID: <20090601060638.GA4256@ff.dom.local>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp> <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp> <1243604796.3966.21.camel@dogo.mojatatu.com> <1243605269.3966.28.camel@dogo.mojatatu.com> <20090529225929.GD2753@ami.dom.local> <1243684218.3966.83.camel@dogo.mojatatu.com> <20090531081213.GC2756@ami.dom.local> <1243776293.3966.241.camel@dogo.mojatatu.com> <20090531195557.GA2777@ami.dom.local> <1243813216.3966.254.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:47751 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbZFAGGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 02:06:43 -0400
Received: by ewy24 with SMTP id 24so7600442ewy.37
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 23:06:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1243813216.3966.254.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 31, 2009 at 07:40:16PM -0400, jamal wrote:
> On Sun, 2009-05-31 at 21:55 +0200, Jarek Poplawski wrote:
> 
> > But then, there could be "tc filter replace" with only this
> > (n->nlmsg_type == RTM_NEWTFILTER && (n->nlmsg_flags&(NLM_F_CREATE)))
> > which can't get here with a newly created tp, I guess.
> 
> Right - because in that case tp would already exist and would
> be found in the lookup.

But how about that (of course extremely rude) case "tc filter replace"
is run with a new prio?

Thanks,
Jarek P.
