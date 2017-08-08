From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v3 net-next 3/5] sock: ULP infrastructure
Date: Tue, 08 Aug 2017 03:16:12 -0700
Message-ID: <59898F6C.3060100@gmail.com>
References: <20170807172818.31855-1-tom@quantonium.net> <20170807172818.31855-4-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rohit@quantonium.net, davejwatson@fb.com
To: Tom Herbert <tom@quantonium.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34469 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751464AbdHHKQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 06:16:22 -0400
Received: by mail-pf0-f194.google.com with SMTP id t86so2637990pfe.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 03:16:22 -0700 (PDT)
In-Reply-To: <20170807172818.31855-4-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2017 10:28 AM, Tom Herbert wrote:
> Generalize the TCP ULP infrastructure recently introduced to support
> kTLS. This adds a SO_ULP socket option and creates new fields in
> sock structure for ULP ops and ULP data. Also, the interface allows
> additional per ULP parameters to be set so that a ULP can be pushed
> and operations started in one shot.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---

I think this generalization should not get committed until it has a user.
I see you posted the socktap stuff but that is just an RFC for now.

[...]

> +
> +static inline void ulp_get_available(char *buf, size_t len)
> +{

Do we need to check len field or is len == 0 invalid?

> +	 *buf = '\0';
> +}
> +
> +static inline void ulp_cleanup(struct sock *sk)
> +{
> +}
> +

[...]


Rest looks OK I'll take a closer look tomorrow at this and the RFC user.

Thanks,
John
