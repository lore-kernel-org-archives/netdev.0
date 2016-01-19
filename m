From: pavi1729 <pavitra1729@gmail.com>
Subject: Re: [PATCH stable-3.14] usb: gadget: f_ncm: fix skb_clone memleak on error
Date: Tue, 19 Jan 2016 12:17:10 +0530
Message-ID: <CAMf7+LgQjGfTwcu+qUCX_oooB=88K7AVyOh1j2Zcj6uzfPjhcg@mail.gmail.com>
References: <1451813841-2359-1-git-send-email-pavitra1729@gmail.com>
	<20160113135349.GG29964@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:34644 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbcASGrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 01:47:11 -0500
In-Reply-To: <20160113135349.GG29964@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Totally missed this. Will test this today and update.


On Wed, Jan 13, 2016 at 7:23 PM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> correct netdev address
>
> * Pavitrakumar Managutte | 2016-01-03 15:07:21 [+0530]:
>
>>Fixed skb_clone pointer memleak on error path. Since the
>>newly cloned skb is still not added to the list, hence purge
>>list wont free the cloned skb.
>>  stable-3.14.y: 5d7b0fcc26
>>
>>Signed-off-by: Pavitrakumar Managutte <pavitra1729@gmail.com>
>
> Can you check if commit 66847062a6e3 ("usb: gadget: NCM: Stop RX TCP
> Bursts getting dropped.") works for you? That would be [0].
> If that is the case then *this* patch should be pushed stable.
>
> [0] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=66847062a6e3
>
> Sebastian
