From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next v5 1/2] af-packet: Added TPACKET_V3 headers.
Date: Thu, 25 Aug 2011 08:58:40 -0400
Message-ID: <CAAsGZS7+nYLBFLaf3Pest-Y-eGOxCVHDQYBipUsTgtvui0XDqQ@mail.gmail.com>
References: <1313785096-911-1-git-send-email-loke.chetan@gmail.com>
	<1313785096-911-2-git-send-email-loke.chetan@gmail.com>
	<20110824.194308.2024908890526228700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:59556 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab1HYM6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 08:58:41 -0400
Received: by qyk38 with SMTP id 38so3289391qyk.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 05:58:40 -0700 (PDT)
In-Reply-To: <20110824.194308.2024908890526228700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2011 at 10:43 PM, David Miller <davem@davemloft.net> wrote:

> Applied.
>
> I would suggest, as a follow-up patch, we add some appropriate
> prefixes to these new datastructures added to if_packet.h as
> these are exposed to userspace.
>

Sure.

> For example "hdr_v1", "bd_ts", "bd_header_u", and "block_desc" are
> just asking for namespace conflicts with something other API in
> userspace or the user's own datastructures.
>

Then just to be consistent, I will prefix it with 'tpacket'.


thanks
Chetan Loke
