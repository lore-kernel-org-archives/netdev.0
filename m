From: David Miller <davem@davemloft.net>
Subject: Re: Flows! Offload them.
Date: Sat, 28 Feb 2015 15:02:33 -0500 (EST)
Message-ID: <20150228.150233.90829668077433241.davem@davemloft.net>
References: <CA+mtBx-sVMNFng_=DcM5mJTbzrRNsFhTvC8YxvjxcqEXwDcWWw@mail.gmail.com>
	<20150226161705.GH1973@nanopsycho.lan>
	<CA+mtBx8r6OGGYXivBc86662peU81Z3UxxZbVS68a_Nadg5p3ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, jpettit@nicira.com, joestringer@nicira.com,
	john.r.fastabend@intel.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbbB1UCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 15:02:37 -0500
In-Reply-To: <CA+mtBx8r6OGGYXivBc86662peU81Z3UxxZbVS68a_Nadg5p3ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 26 Feb 2015 10:15:24 -0800

> But, routing (aka switching) in the stack is not configured through
> TC. We have a whole forwarding and routing infrastructure (eg.
> iproute) with optimizations that  allow routes to be cached in
> sockets, etc. To me, it seems like offloading that basic functionality
> is a prerequisite before attempting to offload more advanced policy
> mechanisms of TC, netfilter, etc.

+1

I think this is the most important post in this entire thread.

The current proposal here is jumping the gun by several weeks if
not months.

We have no idea what roadblocks or design barriers we will hit
with just plain L2 and L3 forwarding yet.

Therefore it is premature to move over to making major decisions
about flow offloading before we've made more progress with the
more fundamental (and in my opinion much more important) offload
facilities.

Jiri, if you want to implement an example set of classifiers in
software that can completely replace openvswitch's datapath, that's
fine.  And it's a completely independant task to designing how we'll
offload flows to hardware in the future.
