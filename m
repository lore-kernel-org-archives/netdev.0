From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 08/33] netns ct: pass netns pointer to L4 protocol's ->error
 hook
Date: Tue, 09 Sep 2008 07:54:11 +0200
Message-ID: <48C60F83.2000006@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-8-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62348 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbYIIFyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 01:54:14 -0400
In-Reply-To: <1220842990-30500-8-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Again, it's deducible from skb, but we're going to use it for
> nf_conntrack_checksum and statistics, so just pass it from upper layer.

Applied, thanks.
