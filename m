From: Patrick McHardy <kaber@trash.net>
Subject: Re: Missing csum_fold() in ip6t_HL.c ?
Date: Fri, 15 Sep 2006 22:19:19 +0200
Message-ID: <450B0AC7.9000607@trash.net>
References: <20060915103755.GB5286@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:18348 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750840AbWIOUTU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 16:19:20 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060915103755.GB5286@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> It looks like "diffs" array is write-only. It also looks like ipv4
> occurences use some csum_fold() trickery. Was is forgotten here? Should
> "diffs" be removed?

Yes, I've queued a patch to remove it. Thanks.

