From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] skb: Add skb_head_is_locked helper function
Date: Thu, 03 May 2012 14:31:02 +0200
Message-ID: <1336048262.3752.9.camel@edumazet-glaptop>
References: <20120503110942.18281.27820.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:53744 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933Ab2ECMbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 08:31:10 -0400
Received: by lbbgm6 with SMTP id gm6so1206760lbb.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 05:31:08 -0700 (PDT)
In-Reply-To: <20120503110942.18281.27820.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-03 at 04:09 -0700, Alexander Duyck wrote:
> This patch adds support for a skb_head_is_locked helper function.  It is
> meant to be used any time we are considering transferring the head from
> skb->head to a paged frag.  If the head is locked it means we cannot remove
> the head from the skb so it must be copied or we must take the skb as a
> whole.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
