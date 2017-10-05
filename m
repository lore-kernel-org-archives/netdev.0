From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/13] timer: Remove init_timer_deferrable() in favor
 of timer_setup()
Date: Wed, 04 Oct 2017 17:41:11 -0700 (PDT)
Message-ID: <20171004.174111.1056977714603579000.davem@davemloft.net>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
        <1507159627-127660-6-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, benh@kernel.crashing.org, mpe@ellerman.id.au,
        sre@kernel.org, harish.patil@cavium.com, manish.chopra@cavium.com,
        kvalo@qca.qualcomm.com, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        akpm@linux-foundation.org, arnd@arndb.de, cmetcalf@mellanox.com,
        geert@linux-m68k.org, gregkh@linuxfoundation.org,
        linux@roeck-us.net, heiko.carstens@de.ibm.com,
        jejb@linux.vnet.ibm.com, john.stultz@linaro.org,
        jwi@linux.vnet.ibm.com, jiangshanlai@gmail.com,
        len.brown@intel.com, mark.gross@intel.com,
        martin.petersen@oracle.com, schwidefsky@de.ibm.com, mdr@sgi.com,
        oleg@redhat.com, paulus@samba.org, pavel@ucw.cz, pmladek@suse.com,
        rjw@rjwysocki.net, ralf@linux-mips.org, stefanr@s5r6.in-berlin.de,
        sboyd@codeaurora.org, sudipm.mukherjee@gmail.co
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56518 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdJEAlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 20:41:14 -0400
In-Reply-To: <1507159627-127660-6-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Wed,  4 Oct 2017 16:26:59 -0700

> This refactors the only users of init_timer_deferrable() to use
> the new timer_setup() and from_timer(). Removes definition of
> init_timer_deferrable().
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Sebastian Reichel <sre@kernel.org>
> Cc: Harish Patil <harish.patil@cavium.com>
> Cc: Manish Chopra <manish.chopra@cavium.com>
> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: netdev@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

For networking:

Acked-by: David S. Miller <davem@davemloft.net>
