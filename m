From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 0/3] tc software only
Date: Tue, 01 Mar 2016 16:06:04 -0500 (EST)
Message-ID: <20160301.160604.1392938206098066808.davem@davemloft.net>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, daniel@iogearbox.net, simon.horman@netronome.com,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	jhs@mojatatu.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbcCAVGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 16:06:07 -0500
In-Reply-To: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 26 Feb 2016 07:53:26 -0800

> This adds a software only flag to tc but incorporates a bunch of comments
> from the original attempt at this.
> 
> First instead of having the offload decision logic be embedded in cls_u32
> I lifted into cls_pkt.h so it can be used anywhere and named the flag
> TCA_CLS_FLAGS_SKIP_HW (Thanks Jiri ;)
> 
> In order to do this I put the flag defines in pkt_cls.h as well. However
> it was suggested that perhaps these flags could be lifted into the
> upper layer of TCA_ as well but I'm afraid this can not be done with
> existing tc design as far as I can tell. The problem is the filters are
> packed and unpacked in the classifier specific code and pushing the flags
> through the high level doesn't seem easily doable. And we already have
> this design where classifiers handle generic options such as actions and
> policers. So I think adding one more thing here is OK as 'tc', et. al.
> already know how to handle this type of thing.

Series applied, thanks John.
