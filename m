From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Fix device name check in netpoll_setup()
Date: Wed, 26 Jul 2017 17:02:11 -0700 (PDT)
Message-ID: <20170726.170211.1958869072074713467.davem@davemloft.net>
References: <20170725183625.132345-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dianders@chromium.org
To: mka@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725183625.132345-1-mka@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Kaehlcke <mka@chromium.org>
Date: Tue, 25 Jul 2017 11:36:25 -0700

> Apparently netpoll_setup() assumes that netpoll.dev_name is a pointer
> when checking if the device name is set:
> 
> if (np->dev_name) {
>   ...
> 
> However the field is a character array, therefore the condition always
> yields true. Check instead whether the first byte of the array has a
> non-zero value.
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

Applied, thanks a lot.
