From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Sun, 29 Mar 2015 20:45:02 -0400
Message-ID: <55189C8E.7070705@mojatatu.com>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us> <1427379836.29436.9.camel@stressinduktion.org> <20150326152938.GD2010@nanopsycho.orion> <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com> <20150327060716.GB2073@nanopsycho.orion> <20150327114402.GB12265@casper.infradead.org> <20150327122846.GA2172@nanopsycho.orion> <20150327123627.GG12265@casper.infradead.org> <20150327124513.GB2172@nanopsycho.orion> <20150327124938.GH12265@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, davem@davemloft.net, jesse@nicira.com
To: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34475 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbbC3ApK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 20:45:10 -0400
Received: by igcau2 with SMTP id au2so62867522igc.1
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 17:45:10 -0700 (PDT)
In-Reply-To: <20150327124938.GH12265@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/15 08:49, Thomas Graf wrote:

> So at that point you get fairly close to cls_flow in terms
> of functionality. Not sure why you want to keep them separate.
>

IMO, it is different enough to be separate.
Flow could do more of course (as could u32) but the lookup
approaches are different. And yes, ONF will probably make a press
release if you called it the openflow classifier (fingers crossed).

cheers,
jamal
