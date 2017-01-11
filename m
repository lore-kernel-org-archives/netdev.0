From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] wext: handle NULL exta data in iwe_stream_add_point better
Date: Wed, 11 Jan 2017 16:00:00 +0100
Message-ID: <CAK8P3a2mOT=BG=9yxJ1e-q__5FYq6dfF3t3bT1vqcgFaQAUjog@mail.gmail.com>
References: <20170111143532.485827-1-arnd@arndb.de> <1484145522.29931.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33239 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938150AbdAKPAB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:00:01 -0500
In-Reply-To: <1484145522.29931.13.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 3:38 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Wed, 2017-01-11 at 15:35 +0100, Arnd Bergmann wrote:

>> This works fine here because iwe->u.data.length is guaranteed to be
>> NULL, and the memcpy doesn't actually have an effect.
>
> I think you mean 0, not NULL, but I can fix that when I apply it.

Right, thanks!

    Arnd
