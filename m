From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wext: handle NULL exta data in iwe_stream_add_point
 better
Date: Wed, 11 Jan 2017 15:38:42 +0100
Message-ID: <1484145522.29931.13.camel@sipsolutions.net>
References: <20170111143532.485827-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170111143532.485827-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-01-11 at 15:35 +0100, Arnd Bergmann wrote:
> gcc-7 complains that wl3501_cs passes NULL into a function that
> then uses the argument as the input for memcpy:
> 
> drivers/net/wireless/wl3501_cs.c: In function 'wl3501_get_scan':
> include/net/iw_handler.h:559:3: error: argument 2 null where non-null 
> expected [-Werror=nonnull]
>    memcpy(stream + point_len, extra, iwe->u.data.length);

I love wext ;-)

> This works fine here because iwe->u.data.length is guaranteed to be
> NULL, and the memcpy doesn't actually have an effect.

I think you mean 0, not NULL, but I can fix that when I apply it.

johannes
