From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [Syncookies]: Add support for TCP options via
 timestamps.
Date: Thu, 10 Apr 2008 03:12:57 -0700 (PDT)
Message-ID: <20080410.031257.07927100.davem@davemloft.net>
References: <1207101252-29941-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ggriffin.kernel@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbYDJKM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 06:12:56 -0400
In-Reply-To: <1207101252-29941-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  2 Apr 2008 03:54:12 +0200

> Allow the use of SACK and window scaling when syncookies are used
> and the client supports tcp timestamps. Options are encoded into
> the timestamp sent in the syn-ack and restored from the timestamp
> echo when the ack is received.
> 
> Based on earlier work by Glenn Griffin.
> This patch avoids increasing the size of structs by encoding TCP
> options into the least significant bits of the timestamp and
> by not using any 'timestamp offset'.
> 
> The downside is that the timestamp sent in the packet after the synack
> will increase by several seconds.
> 
> Reviewed-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> CC: Glenn Griffin <ggriffin.kernel@gmail.com>
> ---
>  changes since v1:
>  don't duplicate timestamp echo decoding function, put it into ipv4/syncookie.c
>  and have ipv6/syncookies.c use it.
>  Feedback from Glenn Griffin: fix line indented with spaces, kill redundant if ()

Looks good, patch applied, thanks!
