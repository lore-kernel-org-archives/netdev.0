From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Fri, 27 Mar 2015 11:44:02 +0000
Message-ID: <20150327114402.GB12265@casper.infradead.org>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
 <1427379836.29436.9.camel@stressinduktion.org>
 <20150326152938.GD2010@nanopsycho.orion>
 <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com>
 <20150327060716.GB2073@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40671 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbbC0LoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 07:44:06 -0400
Content-Disposition: inline
In-Reply-To: <20150327060716.GB2073@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/15 at 07:07am, Jiri Pirko wrote:
> well, you can do *everything* with cls_bpf now that it supports ebpf.
> But I think it is a big hammer. cls_openflow suppose to be just
> replacement for existing ovs classification, with very simple and well
> understood uapi.

The current linear filtering approach makes it not suitable
right now. No doubt that unifying flow classification would
be great to have.

Once you start building some form of wildcarded hash tables
into this, I see a lot of overlap with cls_flow appearing.
What about extending cls_flow instead? Are you still planning
to have one cls_classifier instance per wildcard flow?

I'm usually all for small steps and take it from there but you
are setting a uapi in stone here and once you add linear
filtering behaviour you can't just undo it without a ton of
flags.
