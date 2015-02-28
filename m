From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Flows! Offload them.
Date: Sat, 28 Feb 2015 22:31:32 +0100
Message-ID: <20150228213132.GA21610@nanopsycho.orion>
References: <CA+mtBx-sVMNFng_=DcM5mJTbzrRNsFhTvC8YxvjxcqEXwDcWWw@mail.gmail.com>
 <20150226161705.GH1973@nanopsycho.lan>
 <CA+mtBx8r6OGGYXivBc86662peU81Z3UxxZbVS68a_Nadg5p3ZA@mail.gmail.com>
 <20150228.150233.90829668077433241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com, simon.horman@netronome.com,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, jpettit@nicira.com, joestringer@nicira.com,
	john.r.fastabend@intel.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37720 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbB1Vbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 16:31:37 -0500
Received: by wivr20 with SMTP id r20so7188605wiv.2
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 13:31:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150228.150233.90829668077433241.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 28, 2015 at 09:02:33PM CET, davem@davemloft.net wrote:
>From: Tom Herbert <therbert@google.com>
>Date: Thu, 26 Feb 2015 10:15:24 -0800
>
>> But, routing (aka switching) in the stack is not configured through
>> TC. We have a whole forwarding and routing infrastructure (eg.
>> iproute) with optimizations that  allow routes to be cached in
>> sockets, etc. To me, it seems like offloading that basic functionality
>> is a prerequisite before attempting to offload more advanced policy
>> mechanisms of TC, netfilter, etc.
>
>+1
>
>I think this is the most important post in this entire thread.
>
>The current proposal here is jumping the gun by several weeks if
>not months.
>
>We have no idea what roadblocks or design barriers we will hit
>with just plain L2 and L3 forwarding yet.
>
>Therefore it is premature to move over to making major decisions
>about flow offloading before we've made more progress with the
>more fundamental (and in my opinion much more important) offload
>facilities.

Fair enough. I just felt that the flows are happening just now
(John's work) so I wanted people to stay in focus. But I completely
agree that plain L2, L3 forwarding should be handled first. Then some
of the quirks connected with that, flows and other stuff after.

>
>Jiri, if you want to implement an example set of classifiers in
>software that can completely replace openvswitch's datapath, that's
>fine.  And it's a completely independant task to designing how we'll
>offload flows to hardware in the future.

Nod. Will do that.
