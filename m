From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: drr: check for NULL pointer in drr_dequeue
Date: Fri, 29 Jan 2016 17:27:01 -0800 (PST)
Message-ID: <20160129.172701.536181510037467824.davem@davemloft.net>
References: <CAM_iQpX=x6gvuhxbN7zjbCa+zfyeh0nN86Ao_wVg6f9U3OEJew@mail.gmail.com>
	<1453951851-24501-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, stable@vger.kernel.org
To: bernie.harris@alliedtelesis.co.nz
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1453951851-24501-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Date: Thu, 28 Jan 2016 16:30:51 +1300

> There are cases where qdisc_dequeue_peeked can return NULL, and the result
> is dereferenced later on in the function.
> 
> Similarly to the other qdisc dequeue functions, check whether the skb
> pointer is NULL and if it is, goto out.
> 
> Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>

Applied, thanks.
