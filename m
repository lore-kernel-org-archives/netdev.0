From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v2 1/7] udp: Generic functions to set checksum
Date: Mon, 2 Jun 2014 16:43:04 -0700
Message-ID: <CAHA+R7NYRg8Mt3_=G3728pN2cJSTth49EVfDADCzZCoZ10npJQ@mail.gmail.com>
References: <alpine.DEB.2.02.1406012047250.9052@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:45710 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbaFBXnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:43:06 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so3784873qab.28
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 16:43:04 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406012047250.9052@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 1, 2014 at 9:00 PM, Tom Herbert <therbert@google.com> wrote:
> +
> +
> +/* Function to set UDP checksum for an IPv6 UDP packet. This is intended
> + * for the simple case like when setting the checksum for a UDP tunnel.
> + */
> +static inline void udp6_set_csum(struct sock *sk, struct sk_buff *skb,
> +                                const struct in6_addr *saddr,
> +                                const struct in6_addr *daddr, int len)
> +{

I think this function might be too big to be inlined.

Ditto for udp_set_csum().
