From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] ipv6: fix endianness error in icmpv6_err
Date: Sun, 12 Jun 2016 12:38:30 +0900
Message-ID: <CAKD1Yr1xPFMY50zniE056H438nZdAcHnQ=fE1KANnPM7FA_7Hg@mail.gmail.com>
References: <1465669926-16272-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:34310 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbcFLDiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 23:38:51 -0400
Received: by mail-yw0-f180.google.com with SMTP id c72so100022278ywb.1
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2016 20:38:50 -0700 (PDT)
In-Reply-To: <1465669926-16272-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2016 at 3:32 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> IPv6 ping socket error handler doesn't correctly convert the new 32 bit
> mtu to host endianness before using.
> ...
>         if (!(type & ICMPV6_INFOMSG_MASK))
>                 if (icmp6->icmp6_type == ICMPV6_ECHO_REQUEST)
> -                       ping_err(skb, offset, info);
> +                       ping_err(skb, offset, ntohl(info));
>  }

Acked-by: Lorenzo Colitti <lorenzo@google.com>
