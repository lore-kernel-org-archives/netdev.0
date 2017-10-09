From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] net/mlx4_core: Convert timers to use timer_setup()
Date: Mon, 09 Oct 2017 12:26:11 -0400
Message-ID: <1507566371.46071.39.camel@redhat.com>
References: <20171005005154.GA23500@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005005154.GA23500@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-04 at 17:51 -0700, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list
> pointer to
> all timer callbacks, switch to using the new timer_setup() and
> from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> This requires commit 686fef928bba ("timer: Prepare to change timer
> callback argument type") in v4.14-rc3, but should be otherwise
> stand-alone.

Thanks, applied.

-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
