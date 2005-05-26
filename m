From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.12-rc5 9/9] tg3: Fix bug in tg3_load_firmware_cpu
Date: Thu, 26 May 2005 15:13:47 -0400
Message-ID: <42961FEB.801@pobox.com>
References: <1117128795.3744.22.camel@rh4> <1117130411.3744.61.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1117130411.3744.61.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Add tg3_nvram_lock() and tg3_nvram_unlock() calls around tg3_halt_cpu().
> It is possible that the bootcode may be loading code from nvram during
> this call and stopping the cpu without getting the lock may cause
> uncompleted nvram data to be left in the nvram data register. Subsequent
> calls to read/write nvram data will fail.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

All the patches seem sane to me.

To touch a bit on patch order, I would suggest ordering bug fixes before 
feature patches.  Your patch #9 could have been better ordered as patch #1.

The patch order did not matter today, but sometime in the future, if an 
add-a-feature patch is rejected or delayed, you would still likely want 
DaveM to apply other bugfix patches.

Regards,

	Jeff
