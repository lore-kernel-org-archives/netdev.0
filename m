From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hysdn: fix to a race condition in put_log_buffer
Date: Mon, 31 Jul 2017 17:22:28 -0700 (PDT)
Message-ID: <20170731.172228.890883127209209563.davem@davemloft.net>
References: <8178d591-2b1a-334d-fdd1-4c6b98abad72@ispras.ru>
        <2f35ddaf-88d9-e848-f83b-3001b36b2883@linux-pingi.de>
        <fd42b4de-416a-4e1b-046a-378aa66f7486@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org,
        khoroshilov@ispras.ru
To: avolkov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fd42b4de-416a-4e1b-046a-378aa66f7486@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Volkov <avolkov@ispras.ru>
Date: Fri, 28 Jul 2017 17:53:51 +0300

> The synchronization type that was used earlier to guard the loop that
> deletes unused log buffers may have lead to a situation that prevents
> any thread from going through the loop.
> 
> The patch deletes previously used synchronization mechanism and moves
> the loop under the spin_lock so the similar cases won't be feasible in
> the future.
> 
> Found by by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Anton Volkov <avolkov@ispras.ru>

This patch doesn't apply at all.

It's probably been corrupted by your email client.
