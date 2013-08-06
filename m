From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: [PATCH 3/3] net: wireless: rt2x00: Staticize rt2x00queue_pause_queue_nocheck()
Date: Tue, 6 Aug 2013 12:27:31 +0200
Message-ID: <CAL1gcdNVLRPRTwHMn5RZ4Mq=Mhq=omCN=8+wKiex3innhzCzDA@mail.gmail.com>
References: <000801ce927f$fc7549d0$f55fdd70$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:60769 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755772Ab3HFK1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 06:27:32 -0400
In-Reply-To: <000801ce927f$fc7549d0$f55fdd70$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 6, 2013 at 10:36 AM, Jingoo Han <jg1.han@samsung.com> wrote:
> rt2x00queue_pause_queue_nocheck()is used only in this file.
> Fix the following sparse warning:
>
> drivers/net/wireless/rt2x00/rt2x00queue.c:939:6: warning: symbol 'rt2x00queue_pause_queue_nocheck' was not declared. Should it be
> static?
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Gertjan van Wingerde <gwingerde@gmail.com>

> ---
>  drivers/net/wireless/rt2x00/rt2x00queue.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
> index aa95c6c..6c8a33b 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00queue.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
> @@ -936,7 +936,7 @@ void rt2x00queue_index_inc(struct queue_entry *entry, enum queue_index index)
>         spin_unlock_irqrestore(&queue->index_lock, irqflags);
>  }
>
> -void rt2x00queue_pause_queue_nocheck(struct data_queue *queue)
> +static void rt2x00queue_pause_queue_nocheck(struct data_queue *queue)
>  {
>         switch (queue->qid) {
>         case QID_AC_VO:
> --
> 1.7.10.4
>
>



-- 
---
Gertjan
