From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net_sched: drr: check for NULL pointer in drr_dequeue
Date: Fri, 29 Jan 2016 10:19:16 -0800
Message-ID: <CAM_iQpXVx6xEs==KyiD4-rQu6-Kiu2Q7jC-zPSKXaU4w6CJzqA@mail.gmail.com>
References: <CAM_iQpX=x6gvuhxbN7zjbCa+zfyeh0nN86Ao_wVg6f9U3OEJew@mail.gmail.com>
	<1453951851-24501-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, stable@vger.kernel.org
To: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:33536 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933134AbcA2STR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 13:19:17 -0500
In-Reply-To: <1453951851-24501-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2016 at 7:30 PM, Bernie Harris
<bernie.harris@alliedtelesis.co.nz> wrote:
> There are cases where qdisc_dequeue_peeked can return NULL, and the result
> is dereferenced later on in the function.
>
> Similarly to the other qdisc dequeue functions, check whether the skb
> pointer is NULL and if it is, goto out.
>
> Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
