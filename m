From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] hysdn: fix to a race condition in put_log_buffer
Date: Mon, 07 Aug 2017 11:25:43 -0700 (PDT)
Message-ID: <20170807.112543.687820539253956584.davem@davemloft.net>
References: <a82052eb-2aec-ffa2-2cfd-c02db779d695@cogentembedded.com>
        <1502110454-3996-1-git-send-email-avolkov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, sergei.shtylyov@cogentembedded.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org, khoroshilov@ispras.ru
To: avolkov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502110454-3996-1-git-send-email-avolkov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Volkov <avolkov@ispras.ru>
Date: Mon,  7 Aug 2017 15:54:14 +0300

> The synchronization type that was used earlier to guard the loop that
> deletes unused log buffers may lead to a situation that prevents any
> thread from going through the loop.
> 
> The patch deletes previously used synchronization mechanism and moves
> the loop under the spin_lock so the similar cases won't be feasible in
> the future.
> 
> Found by by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Anton Volkov <avolkov@ispras.ru>
> ---
> v2: Fixed coding style issues

Applied.
