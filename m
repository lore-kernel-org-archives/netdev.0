From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: use event->chunk when it's valid
Date: Mon, 08 Aug 2016 14:34:01 -0700 (PDT)
Message-ID: <20160808.143401.1489906176772169295.davem@davemloft.net>
References: <b2a38bf9d9d9b9b10a3243149badd56fbb971c4e.1470550513.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34626 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbcHHVeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 17:34:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so25707045pfb.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 14:34:03 -0700 (PDT)
In-Reply-To: <b2a38bf9d9d9b9b10a3243149badd56fbb971c4e.1470550513.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun,  7 Aug 2016 14:15:13 +0800

> Commit 52253db924d1 ("sctp: also point GSO head_skb to the sk when
> it's available") used event->chunk->head_skb to get the head_skb in
> sctp_ulpevent_set_owner().
> 
> But at that moment, the event->chunk was NULL, as it cloned the skb
> in sctp_ulpevent_make_rcvmsg(). Therefore, that patch didn't really
> work.
> 
> This patch is to move the event->chunk initialization before calling
> sctp_ulpevent_receive_data() so that it uses event->chunk when it's
> valid.
> 
> Fixes: 52253db924d1 ("sctp: also point GSO head_skb to the sk when it's available")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thank you.
