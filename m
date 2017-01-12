From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wext: handle NULL exta data in iwe_stream_add_point
 better
Date: Thu, 12 Jan 2017 10:16:00 +0100
Message-ID: <1484212560.5391.3.camel@sipsolutions.net>
References: <20170111143532.485827-1-arnd@arndb.de>
         <CAK8P3a2mOT=BG=9yxJ1e-q__5FYq6dfF3t3bT1vqcgFaQAUjog@mail.gmail.com>
         <1484147177.29931.14.camel@sipsolutions.net> <3292373.oxnXTOSWCQ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3292373.oxnXTOSWCQ@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-01-11 at 21:39 +0100, Arnd Bergmann wrote:
> On Wednesday, January 11, 2017 4:06:17 PM CET Johannes Berg wrote:
> > 
> > Applied. Also fixed the typo in the subject :)
> 
> Thanks! Unfortunately I now got another warning for the same
> function, and though I would have expected the patch to fix it, that
> did not work:
> 
> In file included from /git/arm-
> soc/drivers/net/wireless/intersil/prism54/islpci_dev.h:27:0,
>                  from /git/arm-
> soc/drivers/net/wireless/intersil/prism54/isl_ioctl.h:24,
>                  from /git/arm-
> soc/drivers/net/wireless/intersil/prism54/isl_ioctl.c:32:
> /git/arm-soc/drivers/net/wireless/intersil/prism54/isl_ioctl.c: In
> function 'prism54_get_scan':
> /git/arm-soc/include/net/iw_handler.h:560:4: error: argument 2 null
> where non-null expected [-Werror=nonnull]
>     memcpy(stream + point_len, extra, iwe->u.data.length);

And I realized only now that this was a different place ...

I've just added the check you suggested - spent way too much time
already on this old crap :)

johannes
