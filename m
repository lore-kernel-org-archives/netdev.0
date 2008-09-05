From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 05 Sep 2008 14:25:10 +0200
Message-ID: <48C12526.90501@trash.net>
References: <20080821220432.GT31136@x200.localdomain> <48C012B8.10606@trash.net> <20080905025838.GA2789@x200.localdomain> <48C11918.8020508@trash.net> <48C11DF5.9040207@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56759 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbYIEMZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 08:25:13 -0400
In-Reply-To: <48C11DF5.9040207@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>>>> I think you could avoid this mess by using a struct nf_conntrack
>>>> for the untracked conntrack instead of struct nf_conn. It shouldn't
>>>> make any difference since its ignored anyways.
>>> Ewww, can I?
>> I hope so :) A different possiblity suggest by Pablo some time ago
>> would be to mark untracked packets in skb->nfctinfo and not
>> attach a conntrack at all.
> 
> Indeed, I remember that :). I left that patch of the table time ago [1].
> There's a nf_reset call missing as Patrick said at that time. I can
> recover it if you like the idea.

I think that would be a good idea.
