From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp: reorder sctp_globals to reduce
 cacheline usage
Date: Thu, 29 Aug 2013 14:56:06 -0400 (EDT)
Message-ID: <20130829.145606.1418884404797972654.davem@davemloft.net>
References: <1377527640-22447-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754315Ab3H2S4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 14:56:08 -0400
In-Reply-To: <1377527640-22447-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 26 Aug 2013 16:34:00 +0200

> Reduce cacheline usage from 2 to 1 cacheline for sctp_globals structure. By
> reordering elements, we can close gaps and simply achieve the following:
> 
> Current situation:
>   /* size: 80, cachelines: 2, members: 10 */
>   /* sum members: 57, holes: 4, sum holes: 16 */
>   /* padding: 7 */
>   /* last cacheline: 16 bytes */
> 
> Afterwards:
>   /* size: 64, cachelines: 1, members: 10 */
>   /* padding: 7 */
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
