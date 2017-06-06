From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethoc: enable NAPI before poll may be scheduled
Date: Tue, 06 Jun 2017 16:24:43 -0400 (EDT)
Message-ID: <20170606.162443.2275328135132391031.davem@davemloft.net>
References: <1496712676-11862-1-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        thierry.reding@gmail.com, tklauser@distanz.ch,
        stable@vger.kernel.org
To: jcmvbkbc@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1496712676-11862-1-git-send-email-jcmvbkbc@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Max Filippov <jcmvbkbc@gmail.com>
Date: Mon,  5 Jun 2017 18:31:16 -0700

> ethoc_reset enables device interrupts, ethoc_interrupt may schedule a
> NAPI poll before NAPI is enabled in the ethoc_open, which results in
> device being unable to send or receive anything until it's closed and
> reopened. In case the device is flooded with ingress packets it may be
> unable to recover at all.
> Move napi_enable above ethoc_reset in the ethoc_open to fix that.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>

Applied and queued up for -stable.
