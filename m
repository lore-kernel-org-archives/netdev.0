From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/7] kobject: copy env blob in one go
Date: Tue, 19 Sep 2017 13:52:21 -0700
Message-ID: <CAM_iQpXsSYGwbsV-a5XQvcfFGtdn+SrMEGvR=rS53Qe-XY9L3g@mail.gmail.com>
References: <20170918190733.26272-1-edumazet@google.com> <20170918190733.26272-3-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:54618 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdISUwm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 16:52:42 -0400
Received: by mail-pf0-f178.google.com with SMTP id d187so414966pfg.11
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 13:52:42 -0700 (PDT)
In-Reply-To: <20170918190733.26272-3-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 12:07 PM, Eric Dumazet <edumazet@google.com> wrote:
> +                       scratch = skb_put(skb, env->buflen);
> +                       memcpy(scratch, env->buf, env->buflen);

skb_put_data()
