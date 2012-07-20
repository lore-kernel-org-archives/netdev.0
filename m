From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: spin_unlock_irq in interrupt handler fix
Date: Fri, 20 Jul 2012 16:18:57 -0700 (PDT)
Message-ID: <20120720.161857.613443903782303240.davem@davemloft.net>
References: <1342821274-20623-1-git-send-email-yefremov.denis@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.decotigny@google.com, edumazet@google.com, jpirko@redhat.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yefremov.denis@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342821274-20623-1-git-send-email-yefremov.denis@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Efremov <yefremov.denis@gmail.com>
Date: Sat, 21 Jul 2012 01:54:34 +0400

> The replacement of spin_lock_irq/spin_unlock_irq pair in interrupt
> handler by spin_lock_irqsave/spin_lock_irqrestore pair.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Denis Efremov <yefremov.denis@gmail.com>

Applied, thanks.
