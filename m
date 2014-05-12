From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] fq: don't allow set options to zero
Date: Sun, 11 May 2014 22:58:56 -0700
Message-ID: <1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:65280 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbaELF67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 01:58:59 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so3549715pab.19
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 22:58:58 -0700 (PDT)
In-Reply-To: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-12 at 12:18 +0800, Yang Yingliang wrote:
> Now options of fair queue can be zero but cannot be (~0U).
> Zero is useless, so don't allow set the options to zero.
> Also, maxrate cannot be reset to unlimited because it
> cannot be (~0U).
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  tc/q_fq.c | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)

No, you are changing behavior for existing scripts.

If you really want to fix these cases, you need to do it properly.
