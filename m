From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix length overflow in VPD firmware parsing
Date: Wed, 27 Mar 2013 14:11:26 -0400 (EDT)
Message-ID: <20130327.141126.2163700256471831702.davem@davemloft.net>
References: <20130327164050.GA26838@www.outflux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org, oded@privatecore.com,
	spender@grsecurity.net, benli@broadcom.com
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130327164050.GA26838@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 27 Mar 2013 09:40:50 -0700

> Commit 184b89044fb6e2a74611dafa69b1dce0d98612c6 ("tg3: Use VPD fw version
> when present") introduced VPD parsing that contained a potential length
> overflow.
> 
> Limit the hardware's reported firmware string length (max 255 bytes) to
> stay inside the driver's firmware string length (32 bytes). On overflow,
> truncate the formatted firmware string instead of potentially overwriting
> portions of the tg3 struct.
> 
> http://cansecwest.com/slides/2013/PrivateCore%20CSW%202013.pdf
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Reported-by: Oded Horovitz <oded@privatecore.com>
> Reported-by: Brad Spengler <spender@grsecurity.net>

Applied.
