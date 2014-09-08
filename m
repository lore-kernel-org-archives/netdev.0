From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Fix GRE RX to use skb_transport_header for GRE
 header offset
Date: Mon, 8 Sep 2014 10:10:04 -0700
Message-ID: <CA+mtBx-8eGG0aCX+2GhFmhygg44BLrqmt99aVuzv9JuDK4JZ9w@mail.gmail.com>
References: <1410190152-7396-1-git-send-email-therbert@google.com>
	<1410191444.11872.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:47427 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbaIHRKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 13:10:06 -0400
Received: by mail-ig0-f179.google.com with SMTP id r2so3095300igi.0
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 10:10:05 -0700 (PDT)
In-Reply-To: <1410191444.11872.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 8, 2014 at 8:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-09-08 at 08:29 -0700, Tom Herbert wrote:
>> GRE assumes that the GRE header is at skb_network_header +
>> ip_hrdlen(skb). It is more general to use skb_transport_header
>> and this allows the possbility of inserting additional header
>> between IP and GRE (which is what we will done in Generic UDP
>> Encapsulation for GRE).
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  net/ipv4/gre_demux.c | 5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> I am always confused why you do not include prior Acked-by when you
> repost same patch.
>
Sorry, I'll do that next time.

> This forces me to add it again.
>
> Note this should be a net-next patch, right ?
>
Yes.

> Acked-by: Eric Dumazet <edumazet@google.com>
>
>
