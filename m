From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] udp: keep the sk_receive_queue held
 when splicing
Date: Tue, 16 May 2017 07:12:26 -0700
Message-ID: <1494943946.6465.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1494881617.git.pabeni@redhat.com>
         <35e3fc420159a14392b9a2f501f76cc6eb59ba0f.1494881617.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35292 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751035AbdEPOM2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 10:12:28 -0400
Received: by mail-pf0-f194.google.com with SMTP id u26so20091241pfd.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 07:12:28 -0700 (PDT)
In-Reply-To: <35e3fc420159a14392b9a2f501f76cc6eb59ba0f.1494881617.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-16 at 11:20 +0200, Paolo Abeni wrote:
> On packet reception, when we are forced to splice the
> sk_receive_queue, we can keep the related lock held, so
> that we can avoid re-acquiring it, if fwd memory
> scheduling is required.
> 
> v1 -> v2:
>   the rx_queue_lock_held param in udp_rmem_release() is
>   now a bool
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Acked-by: Eric Dumazet <edumazet@google.com>
