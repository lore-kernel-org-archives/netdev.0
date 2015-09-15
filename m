From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] openvswitch: Fix mask generation for nested
 attributes.
Date: Tue, 15 Sep 2015 16:25:52 -0700 (PDT)
Message-ID: <20150915.162552.1124834423380189803.davem@davemloft.net>
References: <1442021908-47034-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbIOXZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 19:25:53 -0400
In-Reply-To: <1442021908-47034-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 11 Sep 2015 18:38:28 -0700

> Masks were added to OVS flows in a way that was backwards compatible
> with userspace programs that did not generate masks. As a result, it is
> possible that we may receive flows that do not have a mask and we need
> to synthesize one.
> 
> Generating a mask requires iterating over attributes and descending into
> nested attributes. For each level we need to know the size to generate the
> correct mask. We do this with a linked table of attribute types.
> 
> Although the logic to handle these nested attributes was there in concept,
> there are a number of bugs in practice. Examples include incomplete links
> between tables, variable length attributes being treated as nested and
> missing sanity checks.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
> v2: Fix whitespace errors.
>     Add check for unknown bytes in VXLAN extensions.
>     Factor out check for nested or variable attributes.

Applied, thanks.
