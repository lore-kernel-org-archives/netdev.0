From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-ircc: don't return zero if via_ircc_open() failed
Date: Tue, 20 Aug 2013 13:27:48 -0700 (PDT)
Message-ID: <20130820.132748.2038341239691937544.davem@davemloft.net>
References: <1376686094-28780-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376686094-28780-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Fri, 16 Aug 2013 23:48:14 +0300

> If via_ircc_open() fails, data structures of the driver left uninitialized,
> but probe (via_init_one()) returns zero. That can lead to null pointer dereference
> in via_remove_one(), since it does not check drvdata for NULL.
> 
> The patch implements proper error code propagation.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied, thanks.
