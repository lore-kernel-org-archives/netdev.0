From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 1/3] net: bcmgenet: cleanup for bcmgenet_xmit()
Date: Wed, 6 Apr 2016 12:09:15 -0700
Message-ID: <CAGXr9JGfQAYEorhmBd9iDidTRNayyjT-3YxAuoYvDEtpV_kKvQ@mail.gmail.com>
References: <1459815001-91703-1-git-send-email-pgynther@google.com>
	<063D6719AE5E284EB5DD2968C1650D6D54DC5E88@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"jaedon.shin@gmail.com" <jaedon.shin@gmail.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:36698 "EHLO
	mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbcDFTJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 15:09:17 -0400
Received: by mail-vk0-f49.google.com with SMTP id c4so71024696vkb.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 12:09:16 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D54DC5E88@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 1:57 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Petri Gynther
>> Sent: 05 April 2016 01:10
> ...
>> 2. Readability: Add parentheses around nr_frags + 1.
> ...
>> -     if (ring->free_bds <= nr_frags + 1) {
> ...
>> +     if (ring->free_bds <= (nr_frags + 1)) {
>
> The extra () are not needed and do not improve readability.
>
>         David
>

Not needed from C language point of view, but I personally like it
better that way.

Also, making it consistent with these:
bcmgenet.c:1227: if (ring->free_bds > (MAX_SKB_FRAGS + 1)) {
bcmgenet.c:1523: if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
