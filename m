From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH stable-3.14] usb: gadget: f_ncm: fix skb_clone memleak on
 error
Date: Wed, 13 Jan 2016 14:53:49 +0100
Message-ID: <20160113135349.GG29964@linutronix.de>
References: <1451813841-2359-1-git-send-email-pavitra1729@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Pavitrakumar Managutte <pavitra1729@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:49983 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647AbcAMNxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 08:53:51 -0500
Content-Disposition: inline
In-Reply-To: <1451813841-2359-1-git-send-email-pavitra1729@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

correct netdev address

* Pavitrakumar Managutte | 2016-01-03 15:07:21 [+0530]:

>Fixed skb_clone pointer memleak on error path. Since the
>newly cloned skb is still not added to the list, hence purge
>list wont free the cloned skb.
>  stable-3.14.y: 5d7b0fcc26
>
>Signed-off-by: Pavitrakumar Managutte <pavitra1729@gmail.com>

Can you check if commit 66847062a6e3 ("usb: gadget: NCM: Stop RX TCP
Bursts getting dropped.") works for you? That would be [0].
If that is the case then *this* patch should be pushed stable.

[0] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=66847062a6e3

Sebastian
