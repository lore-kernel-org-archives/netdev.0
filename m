From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix flowlabel seqfile handling
Date: Tue, 31 Oct 2006 00:44:31 -0800 (PST)
Message-ID: <20061031.004431.63126878.davem@davemloft.net>
References: <Pine.LNX.4.64.0610310034500.14627@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58088
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422888AbWJaIod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 03:44:33 -0500
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0610310034500.14627@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Tue, 31 Oct 2006 01:20:21 -0500 (EST)

> There's a bug in the seqfile show operation for flowlabel objects, where 
> each hash chain is traversed cumulatively for each element.  The following 
> function is called for each element of each chain:

Wow, there are tons of bugs in the flowlabel code, at least
judging by the number of them you've found in the past few
days :-)

Applied, thanks a lot for all of these fixes James.
