From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 05/16] tcp: switch back to proper tcp_skb_cb
 size check in tcp_init()
Date: Mon, 19 Sep 2016 07:41:02 -0700
Message-ID: <CANn89i+LDSsXuSaUxfVNx2bT1YhFXjoYVpxz4G7T4X+jXAUgcQ@mail.gmail.com>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
 <1474236233-28511-6-git-send-email-ncardwell@google.com> <270694554.494524.1474295826754.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f176.google.com ([209.85.213.176]:35309 "EHLO
        mail-yb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbcISOlE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 10:41:04 -0400
Received: by mail-yb0-f176.google.com with SMTP id d69so87255658ybf.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 07:41:04 -0700 (PDT)
In-Reply-To: <270694554.494524.1474295826754.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 7:37 AM, Lance Richardson <lrichard@redhat.com> wrote:

> The skb local variable could be avoided via:
>
>         BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
>

Right you are, thanks !
