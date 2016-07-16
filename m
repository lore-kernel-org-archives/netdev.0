From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH] sctp: load transport header after sk_filter
Date: Sat, 16 Jul 2016 17:36:52 -0400
Message-ID: <CAF=yD-JSc9mRC7TfLnM5jA-wtTA50VOYCQvQKsxWrFskaUPFRQ@mail.gmail.com>
References: <1468704795-134034-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34150 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbcGPVhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 17:37:33 -0400
Received: by mail-vk0-f52.google.com with SMTP id o63so197800652vkg.1
        for <netdev@vger.kernel.org>; Sat, 16 Jul 2016 14:37:32 -0700 (PDT)
In-Reply-To: <1468704795-134034-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Do not cache pointers into the skb linear segment across sk_filter.
> The function call can trigger pskb_expand_head.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

This is targeted at net.

I forgot to pass the right --subject-prefix='PATCH net'
