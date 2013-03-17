From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: Re: [PATCHv3 vringh] caif_virtio: Introduce caif over virtio
Date: Mon, 18 Mar 2013 00:52:19 +0200
Message-ID: <CAK=WgbbV6mvYC+KeSKJR+jmrAy3Et5opzzno1_kaicMPdDxNXg@mail.gmail.com>
References: <1363340537-16011-1-git-send-email-erwan.yvin@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Rusty Russel <rusty@ruscorp.com.au>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Linus Walleij <linus.walleij@stericsson.com>,
	virtualization <virtualization@lists.linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Erwan Yvin <erwan.yvin@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:46657 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698Ab3CQWwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 18:52:41 -0400
Received: by mail-lb0-f169.google.com with SMTP id m4so4176394lbo.28
        for <netdev@vger.kernel.org>; Sun, 17 Mar 2013 15:52:39 -0700 (PDT)
In-Reply-To: <1363340537-16011-1-git-send-email-erwan.yvin@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Erwan,

On Fri, Mar 15, 2013 at 11:42 AM, Erwan Yvin <erwan.yvin@stericsson.com> wrote:
> diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_virtio.c
> new file mode 100644
> index 0000000..6a745dd
> --- /dev/null
> +++ b/drivers/net/caif/caif_virtio.c
> @@ -0,0 +1,786 @@
> +/*
> + * Copyright (C) ST-Ericsson AB 2013
> + * Authors: Vicram Arv / vikram.arv@stericsson.com,
> + *         Dmitry Tarnyagin / dmitry.tarnyagin@stericsson.com
> + *         Sjur Brendeland / sjur.brandeland@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +#include <linux/module.h>
> +#include <linux/if_arp.h>
> +#include <linux/virtio.h>
> +#include <linux/vringh.h>
> +#include <linux/debugfs.h>
> +#include <linux/spinlock.h>
> +#include <linux/genalloc.h>
> +#include <linux/interrupt.h>
> +#include <linux/netdevice.h>
> +#include <linux/rtnetlink.h>
> +#include <linux/remoteproc.h>

The driver looks nicely decoupled from remoteproc - do you still need
remoteproc.h ?

Thanks,
Ohad.
