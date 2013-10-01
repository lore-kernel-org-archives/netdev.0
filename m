From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Subject: Re: [PATCH] ll_temac: Reset dma descriptors on ndo_open
Date: Tue, 1 Oct 2013 08:18:12 +0200
Message-ID: <CAPybu_1s2m7RzTuj7J-_ddz8C56RDa53Vwid2wdTc4dkM6s3cQ@mail.gmail.com>
References: <1380281068-13269-1-git-send-email-ricardo.ribalda@gmail.com>
 <20130930.212153.531876068589922786.davem@davemloft.net> <CAPybu_0OrwTo7CkuauRpu_ohQRY80U6BJDXQ6=KC0caOFiFCQA@mail.gmail.com>
 <20131001.020134.756782177490714135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: joe@perches.com, jg1.han@samsung.com,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	wfp5p@virginia.edu, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131001.020134.756782177490714135.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just send a v2 of the patch

http://patchwork.ozlabs.org/patch/279339/

Thanks!

On Tue, Oct 1, 2013 at 8:01 AM, David Miller <davem@davemloft.net> wrote:
> From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
> Date: Tue, 1 Oct 2013 07:46:31 +0200
>
>> What if I move
>>        lp->tx_bd_ci = 0;
>>        lp->tx_bd_next = 0;
>>        lp->tx_bd_tail = 0;
>>        lp->rx_bd_ci = 0;
>>
>> to temac_dma_bd_init? Will this be more correct?
>
> Yes, that would be a lot better.



-- 
Ricardo Ribalda
