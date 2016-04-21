From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net 0/2] tcp: Merge timestamp info when coalescing skbs
Date: Thu, 21 Apr 2016 15:58:46 -0400
Message-ID: <CAF=yD-JzyU6EcLR7XK6dEk4ifKj8s1=wDEngz763et2u73V05g@mail.gmail.com>
References: <1461130769-1442865-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35223 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbcDUT71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:59:27 -0400
Received: by mail-lf0-f68.google.com with SMTP id u64so1123782lff.2
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 12:59:26 -0700 (PDT)
In-Reply-To: <1461130769-1442865-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 1:39 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> This series is separated from the RFC series related to
> tcp_sendmsg(MSG_EOR) and it is targeting for the net branch.
> This patchset is focusing on fixing cases where TCP
> timestamp could be lost after coalescing skbs.

Thanks for fixing these edge cases, Martin. And for the detailed
packetdrill tests to reproduce them. Those are very informative.

It took me too long to study the retransmit and especially the SACK
code to Ack the patches in a timely manner. But, yes, these code
paths had definitely escaped me when working on the earlier tcp
timestamping patches. Fixes look great, too, so fwiw a belated

Acked-by: Willem de Bruijn <willemb@google.com>
