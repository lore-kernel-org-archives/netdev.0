From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] fib_trie: Fix the description of pos and bits
Date: Thu, 18 Aug 2016 09:26:36 -0700
Message-ID: <CAKgT0UeYXFNaRi-wbS76AOJ+KiVYN3tqXc8x-EzF-TdMQd_Mww@mail.gmail.com>
References: <1471494808-22475-1-git-send-email-xlpang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <alexander.h.duyck@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Xunlei Pang <xlpang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34406 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbcHSE0C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 00:26:02 -0400
In-Reply-To: <1471494808-22475-1-git-send-email-xlpang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 9:33 PM, Xunlei Pang <xlpang@redhat.com> wrote:
> 1) Fix one typo: s/tn/tp/
> 2) Fix the description about the "u" bits.
>
> Signed-off-by: Xunlei Pang <xlpang@redhat.com>
> ---
>  net/ipv4/fib_trie.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index d07fc07..eb7c5d1 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -249,7 +249,7 @@ static inline unsigned long get_index(t_key key, struct key_vector *kv)
>   * index into the parent's child array. That is, they will be used to find
>   * 'n' among tp's children.
>   *
> - * The bits from (n->pos + n->bits) to (tn->pos - 1) - "S" - are skipped bits
> + * The bits from (n->pos + n->bits) to (tp->pos - 1) - "S" - are skipped bits
>   * for the node n.
>   *
>   * All the bits we have seen so far are significant to the node n. The rest
> @@ -258,7 +258,7 @@ static inline unsigned long get_index(t_key key, struct key_vector *kv)
>   * The bits from (n->pos) to (n->pos + n->bits - 1) - "C" - are the index into
>   * n's child array, and will of course be different for each child.
>   *
> - * The rest of the bits, from 0 to (n->pos + n->bits), are completely unknown
> + * The rest of the bits, from 0 to (n->pos -1) - "u" - are completely unknown
>   * at this point.
>   */
>

These comment fixes all look correct.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
