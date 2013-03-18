From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv3 vringh] caif_virtio: Introduce caif over virtio
Date: Mon, 18 Mar 2013 14:15:36 +1030
Message-ID: <87ip4ps74v.fsf@rustcorp.com.au>
References: <1363340537-16011-1-git-send-email-erwan.yvin@stericsson.com> <CAK=WgbbV6mvYC+KeSKJR+jmrAy3Et5opzzno1_kaicMPdDxNXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Rusty Russel <rusty@ruscorp.com.au>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Linus Walleij <linus.walleij@stericsson.com>,
	virtualization <virtualization@lists.linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
To: Ohad Ben-Cohen <ohad@wizery.com>,
	Erwan Yvin <erwan.yvin@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44720 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989Ab3CRISL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 04:18:11 -0400
In-Reply-To: <CAK=WgbbV6mvYC+KeSKJR+jmrAy3Et5opzzno1_kaicMPdDxNXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ohad Ben-Cohen <ohad@wizery.com> writes:
> Hi Erwan,
>
> On Fri, Mar 15, 2013 at 11:42 AM, Erwan Yvin <erwan.yvin@stericsson.com> wrote:
>> +++ b/drivers/net/caif/caif_virtio.c
...
>> +#include <linux/remoteproc.h>
>
> The driver looks nicely decoupled from remoteproc - do you still need
> remoteproc.h ?

Seems not.

Thanks,
Rusty.

caif_virtio: remove unneeded remoteproc.h

Reported-by: Ohad Ben-Cohen <ohad@wizery.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_virtio.c
index 6a745dd..b1e1205 100644
--- a/drivers/net/caif/caif_virtio.c
+++ b/drivers/net/caif/caif_virtio.c
@@ -15,7 +15,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
-#include <linux/remoteproc.h>
 #include <linux/virtio_ids.h>
 #include <linux/virtio_caif.h>
 #include <linux/virtio_ring.h>
