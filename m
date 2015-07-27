From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add support for router
 add/del notifications monitoring
Date: Mon, 27 Jul 2015 14:40:18 -0700
Message-ID: <20150727144018.1ffb2119@urahara>
References: <1437997445-29541-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35963 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbbG0VkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:40:09 -0400
Received: by pachj5 with SMTP id hj5so57451561pac.3
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:40:08 -0700 (PDT)
In-Reply-To: <1437997445-29541-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jul 2015 13:44:05 +0200
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch adds support for ADDMDB/DELMDB notifications about router ports
> which have been added or deleted/expired respectively.
> 
> Example output:
> $ bridge -s monitor mdb
> Deleted router port dev eth3 master br0
> router port dev eth3 master br0
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Looks useful, applied.

Does usage or manual page need to be updated as well?
