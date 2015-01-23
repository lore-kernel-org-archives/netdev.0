From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 16:00:58 +0000
Message-ID: <20150123160058.GN25797@casper.infradead.org>
References: <54C11ACC.5010005@mojatatu.com>
 <20150123101019.GF25797@casper.infradead.org>
 <20150123102421.GB2065@nanopsycho.orion>
 <20150123110821.GH25797@casper.infradead.org>
 <20150123113934.GD2065@nanopsycho.orion>
 <20150123122838.GI25797@casper.infradead.org>
 <20150123134315.GF2065@nanopsycho.orion>
 <20150123140724.GJ25797@casper.infradead.org>
 <54C26A1F.6060603@gmail.com>
 <20150123155332.GJ2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47734 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbbAWQA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 11:00:59 -0500
Content-Disposition: inline
In-Reply-To: <20150123155332.GJ2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 at 04:53pm, Jiri Pirko wrote:
> Fri, Jan 23, 2015 at 04:34:55PM CET, john.fastabend@gmail.com wrote:
> >What I don't have a lot of use for at the moment is an xflows that runs
> >in software? Conceptually it sounds fine but why would I want to mirror
> >hardware limitations into software? And if I make it completely generic
> >it becomes u32 more or less. I could create an optimized version of the
> >hardware dataplane in userspace which sits somewhere between u32 and the
> >other classifiers on flexility and maybe gains some performance but I'm
> >at a loss as to why this is useful. I would rather spend my time getting
> >better performance out of u32 and dropping qdisc_lock completely then
> >writing some partially useful filter for software.
> 
> Well, even software implementation has limitations. Take ovs kernel
> datapath as example. You can use your graphs to describe exactly what
> ovs can handle. And after that you could use xflows api to set it up as
> well as your rocker offload. That to me seems lie a very nice feature to
> have.

What is the value of this? The OVS kernel datapath is already built to
fall back to user space if the kernel datapath does not support a
specific feature.
