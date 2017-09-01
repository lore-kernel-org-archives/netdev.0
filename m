From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] flow_dissector: Cleanup control flow
Date: Fri, 01 Sep 2017 14:35:59 +0200
Message-ID: <87k21izjdc.fsf@stressinduktion.org>
References: <20170831222239.21509-1-tom@quantonium.net>
        <20170831222239.21509-2-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, alex.popov@linux.com
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59101 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751778AbdIAMgC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 08:36:02 -0400
In-Reply-To: <20170831222239.21509-2-tom@quantonium.net> (Tom Herbert's
        message of "Thu, 31 Aug 2017 15:22:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@quantonium.net> writes:

> __skb_flow_dissect is riddled with gotos that make discerning the flow,
> debugging, and extending the capability difficult. This patch
> reorganizes things so that we only perform goto's after the two main
> switch statements (no gotos within the cases now). It also eliminates
> several goto labels so that there are only two labels that can be target
> for goto.

The problem with the

fdret = ... ;
break;

is that we now have to count curly braces to look what break does
actually break and where fdret is being processed. With the number of
context lines you send for the patch this is hard to review.

I tend to like the gotos a bit more for now.

[...]

Bye,
Hannes
