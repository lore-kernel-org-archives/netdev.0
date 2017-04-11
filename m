From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Tue, 11 Apr 2017 11:27:33 -0400 (EDT)
Message-ID: <20170411.112733.1412982560568816717.davem@davemloft.net>
References: <20170411010436.23290-2-benh@kernel.crashing.org>
        <7d0f6000-3be5-ed70-49d3-3a3916dd79ff@cogentembedded.com>
        <1491909225.4166.248.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60662 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753035AbdDKP1f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 11:27:35 -0400
In-Reply-To: <1491909225.4166.248.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 11 Apr 2017 21:13:45 +1000

> On Tue, 2017-04-11 at 13:57 +0300, Sergei Shtylyov wrote:
>>     Need {} here as well since the 1st branch has it -- see 
>> Documentation/process/coding-style.rst (the end of the section 3).
> 
> Adding {} in that specific statements just makes things more
> cluttered and less readable.
> 
> I can find a ton of examples of 
> 
> 	if (...) {
> 		multi lines
> 		...
> 	} else if (...)
> 		single_line()
> 
> In existing kernel code.

Existing practice not following the coding style rules does not dictate
that it's OK to do so.

> I'll fix it in a next spin if Dave wants it that way but otherwise
> I'm keen to leave it as it is.

Please fix this and respin.

Meanwhile get the coding style rules changed if you disagree with
them.  A patch series review is not the place to argue about your
disagreement with the coding style rules.

Thanks.
