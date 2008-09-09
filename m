From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 04/33] Fix {ip,6}_route_me_harder() in netns
Date: Tue, 09 Sep 2008 07:44:30 +0200
Message-ID: <48C60D3E.1060802@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-4-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62155 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbYIIFod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 01:44:33 -0400
In-Reply-To: <1220842990-30500-4-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Take netns from skb->dst->dev. It should be safe because, they are called
> from LOCAL_OUT hook where dst is valid (though, I'm not exactly sure about
> IPVS and queueing packets to userspace).

Its safe in all cases since they already expect to only get
called when skb->dst is valid.

Applied, thanks.
