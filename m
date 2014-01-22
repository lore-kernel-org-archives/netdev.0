From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/0] reciprocal_divide update
Date: Tue, 21 Jan 2014 23:20:01 -0800 (PST)
Message-ID: <20140121.232001.48714613002250339.davem@davemloft.net>
References: <1390354181-5080-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbaAVHUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:20:02 -0500
In-Reply-To: <1390354181-5080-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 22 Jan 2014 02:29:38 +0100

> This patch is on top of aee636c4809fa5 ("bpf: do not use reciprocal
> divide") from Eric that sits in net tree. It will not create a merge
> conflict, but it depends on this one, so we suggest, if possible, to
> merge net into net-next.
> 
> We are proposing this change with only small modifications from the
> v2 version, namely updating the name of trim to reciprocal_scale
> (as commented on by Ben Hutchings and Eric Dumazet, thanks!).
> 
> We thought about introducing the reciprocal_divide algorithm in
> parallel to the one already used by the kernel but faced organizational
> issues, leading us to the conclusion that it is best to just replace
> the old one: We could not come up with names for the different
> implementations and also with a way to describe the differences to
> guide developers which one to choose in which situation. This is
> because we cannot specify the correct semantics for the version
> which is currently used by the kernel. Altough it seems to not be
> causing problems in the kernel, we cannot surely say so in the
> case of flex_array for the future. Current usage seems ok, but
> future users could run into problems.

Series applied, thanks.
