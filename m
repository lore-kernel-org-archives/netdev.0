From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix SYN-data space mis-accounting
Date: Fri, 22 Feb 2013 11:40:58 -0800
Message-ID: <1361562058.3683.15.camel@edumazet-glaptop>
References: <1361559546-1538-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:56360 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276Ab3BVTlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 14:41:01 -0500
Received: by mail-da0-f52.google.com with SMTP id f10so504753dak.39
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 11:41:00 -0800 (PST)
In-Reply-To: <1361559546-1538-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-22 at 10:59 -0800, Yuchung Cheng wrote:
> In fast open the sender unncessarily reduces the space available
> for data in SYN by 12 bytes.  This is because in the sender
> incorrectly reserves space for TS option twice in tcp_send_syn_data():
> tcp_mtu_to_mss() already accounts for TS option space. But it further
> reserves MAX_TCP_OPTION_SPACE when computing the payload space.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
