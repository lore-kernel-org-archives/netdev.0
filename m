From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv4: Do not cache routing failures due to disabled
 forwarding.
Date: Wed, 29 Oct 2014 15:03:28 -0400 (EDT)
Message-ID: <20141029.150328.530876391340346443.davem@davemloft.net>
References: <1410531260-13794-1-git-send-email-nicolas.cavallari@green-communications.fr>
	<1410531260-13794-2-git-send-email-nicolas.cavallari@green-communications.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: nicolas.cavallari@green-communications.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198AbaJ2TDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:03:31 -0400
In-Reply-To: <1410531260-13794-2-git-send-email-nicolas.cavallari@green-communications.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Date: Fri, 12 Sep 2014 16:14:20 +0200

> If we cache them, the kernel will reuse them, independently of
> whether forwarding is enabled or not.  Which means that if forwarding is
> disabled on the input interface where the first routing request comes
> from, then that unreachable result will be cached and reused for
> other interfaces, even if forwarding is enabled on them.
> 
> This can be verified with two interfaces A and B and an output interface
> C, where B has forwarding enabled, but not A and trying
> ip route get $dst iif A from $src && ip route get $dst iif B from $src
> 
> Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
> ---
> based on net-next, but not really tested on top of it.

Sorry Nicolas, this seems to have fallen on the floor.  Could you please
resubmit your most uptodate version of this patch so I can apply it?

Thanks.
