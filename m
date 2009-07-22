From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: remove unnecessary assignment
Date: Wed, 22 Jul 2009 09:59:33 -0700
Message-ID: <20090722095933.0db8c2c8@nehalam>
References: <392fb48f0907211751k6bbbb6base944c6b7d80a3bf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51873 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbZGVQ7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 12:59:39 -0400
In-Reply-To: <392fb48f0907211751k6bbbb6base944c6b7d80a3bf5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jul 2009 09:51:20 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
>  drivers/net/sky2.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 3550c5d..661abd0 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -4117,7 +4117,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)
> 
>  	seq_printf(seq, "\nRx ring hw get=%d put=%d last=%d\n",
>  		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_GET_IDX)),
> -		   last = sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
> +		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
>  		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_LAST_IDX)));
> 
>  	sky2_read32(hw, B0_Y2_SP_LISR);

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
