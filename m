From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Fri, 27 Mar 2015 12:49:38 +0000
Message-ID: <20150327124938.GH12265@casper.infradead.org>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
 <1427379836.29436.9.camel@stressinduktion.org>
 <20150326152938.GD2010@nanopsycho.orion>
 <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com>
 <20150327060716.GB2073@nanopsycho.orion>
 <20150327114402.GB12265@casper.infradead.org>
 <20150327122846.GA2172@nanopsycho.orion>
 <20150327123627.GG12265@casper.infradead.org>
 <20150327124513.GB2172@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41090 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410AbbC0Mtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 08:49:39 -0400
Content-Disposition: inline
In-Reply-To: <20150327124513.GB2172@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/15 at 01:45pm, Jiri Pirko wrote:
> Fri, Mar 27, 2015 at 01:36:27PM CET, tgraf@suug.ch wrote:
> >You'll probably end up with a hash as well. I doubt that you
> >want to walk through a linear list of matches in the long term.
> >Not sure about your plans though.
> 
> Sure, that was supposed next step, to change this to hash list.

So at that point you get fairly close to cls_flow in terms
of functionality. Not sure why you want to keep them separate.
