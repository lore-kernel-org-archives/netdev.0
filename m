From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Fri, 5 Feb 2016 00:19:27 +0100
Message-ID: <20160204231927.GA2347@salvia>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160204091656.GA2198@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, amir@vadai.me,
	ogerlitz@mellanox.com, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47273 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbcBDXTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 18:19:37 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 886066C14
	for <netdev@vger.kernel.org>; Fri,  5 Feb 2016 00:19:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 793BDDA86B
	for <netdev@vger.kernel.org>; Fri,  5 Feb 2016 00:19:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7D745DA804
	for <netdev@vger.kernel.org>; Fri,  5 Feb 2016 00:19:32 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20160204091656.GA2198@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 04, 2016 at 10:16:56AM +0100, Jiri Pirko wrote:
> Wed, Feb 03, 2016 at 10:27:32AM CET, john.fastabend@gmail.com wrote:
> >
> >Also by adding get_parse_graph and set_parse_graph attributes as
> >in my previous flow_api work we can build programmable devices
> >and programmatically learn when rules can or can not be loaded
> >into the hardware. Again future work.
> >
> >Any comments/feedback appreciated.
> 
> I like this being thin and elegant solution. However, ~2 years ago when I
> pushed openvswitch kernel datapath offload patchset, people were yelling
> at me that it is not generic enough solution, that tc has to be able
> to use the api (Jamal :)), nftables as well.

I would be glad to join this debate during NetDev 1.1 too.

I think we should provide a solution that allows people uses both
tc and nftables, this would require a bit of generic infrastructure on
top of it so we don't restrict users to one single solution, in other
words, we allow the user to select its own poison.

> Now this patch is making offload strictly tc-based and nobody seems to
> care :) I do. I think that we might try to find some generic middle layer.

I agree and I'll be happy to help to push this ahead. Let's try to sit
and get together to resolve this.

See you soon.
