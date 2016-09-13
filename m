From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bridge: add helper to call
 /sbin/bridge-stp
Date: Tue, 13 Sep 2016 11:22:42 -0400 (EDT)
Message-ID: <20160913.112242.2097095000095740530.davem@davemloft.net>
References: <20160908165043.31042-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, stephen@networkplumber.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160908165043.31042-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu,  8 Sep 2016 12:50:43 -0400

> If /sbin/bridge-stp is available on the system, bridge tries to execute
> it instead of the kernel implementation when starting/stopping STP.
> 
> If anything goes wrong with /sbin/bridge-stp, bridge silently falls back
> to kernel STP, making hard to debug userspace STP.
> 
> This patch adds a br_stp_call_user helper to start/stop userspace STP
> and debug errors from the program: abnormal exit status is stored in the
> lower byte and normal exit status is stored in higher byte.
> 
> Below is a simple example on a kernel with dynamic debug enabled:
> 
>     # ln -s /bin/false /sbin/bridge-stp
>     # brctl stp br0 on
>     br0: failed to start userspace STP (256)
>     # dmesg
>     br0: /sbin/bridge-stp exited with code 1
>     br0: failed to start userspace STP (256)
>     br0: using kernel STP
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
