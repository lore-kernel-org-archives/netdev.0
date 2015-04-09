From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Thu, 09 Apr 2015 17:34:23 -0400 (EDT)
Message-ID: <20150409.173423.2258417584616634411.davem@davemloft.net>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbbDIVeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 17:34:25 -0400
In-Reply-To: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  9 Apr 2015 14:58:07 +0200

> This patch introduces OpenFlow-based filter. So far, the very essential
> packet fields are supported (according to OpenFlow v1.4 spec).
> 
> This patch is only the first step. There is a lot of potential performance
> improvements possible to implement. Also a lot of features are missing
> now. They will be addressed in follow-up patches.
> 
> To the name of this classifier, I believe that "cls_openflow" is pretty
> accurate. It is actually a OpenFlow classifier.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

I'm not so sure what my opinion is about whether we should
even have an openflow classifier or not (I find major aspects
of OpenFLOW extremely distasteful, it's basically pushing the
SDK agenda of several major chip vendors).

However I am sure that I majorly object to having yet another flow
parsing engine.  Therefore, at least adjust this code to use our flow
dissector and datastructures.  Adjust the flow dissector to fit your
needs, if necessary.
