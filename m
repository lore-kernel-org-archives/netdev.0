From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] net-timestamp: optimize sock_tx_timestamp
 default path
Date: Mon, 8 Sep 2014 19:29:43 -0400
Message-ID: <CA+FuTSfZREU47pDzfDy=EnzVLqCxMmNQavyUFfzs2Um07YhNWw@mail.gmail.com>
References: <1410218824-18296-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:41637 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009AbaIHXaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 19:30:14 -0400
Received: by mail-qg0-f48.google.com with SMTP id z107so16180634qgd.21
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 16:30:13 -0700 (PDT)
In-Reply-To: <1410218824-18296-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Few packets have timestamping enabled. Exit sock_tx_timestamp quickly
> in this common case.
>
> Packets are only possibly timestamped if one of
> SOF_TIMESTAMPING_(SOFTWARE|RAW_HARDWARE) is enabled.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

I submitted this too soon. I hadn't noticed that SOCK_WIFI_STATUS is
also possibly set in sock_tx_timestamp. Let me take another look.
Apologies for the churn.
