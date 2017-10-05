From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/13] timer: Remove init_timer_pinned() in favor of
 timer_setup()
Date: Wed, 04 Oct 2017 17:41:34 -0700 (PDT)
Message-ID: <20171004.174134.1260012045520624727.davem@davemloft.net>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
        <1507159627-127660-5-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, cmetcalf@mellanox.com, netdev@vger.kernel.org,
        akpm@linux-foundation.org, arnd@arndb.de, benh@kernel.crashing.org,
        geert@linux-m68k.org, gregkh@linuxfoundation.org,
        linux@roeck-us.net, harish.patil@cavium.com,
        heiko.carstens@de.ibm.com, jejb@linux.vnet.ibm.com,
        john.stultz@linaro.org, jwi@linux.vnet.ibm.com,
        kvalo@qca.qualcomm.com, jiangshanlai@gmail.com,
        len.brown@intel.com, manish.chopra@cavium.com,
        mark.gross@intel.com, martin.petersen@oracle.com,
        schwidefsky@de.ibm.com, mpe@ellerman.id.au, mdr@sgi.com,
        oleg@redhat.com, paulus@samba.org, pavel@ucw.cz, pmladek@suse.com,
        rjw@rjwysocki.net, ralf@linux-mips.org, sre@kernel.org,
        stefanr@s5r6.in-berlin.de, sboyd@codeaurora.org,
        sudipm.mukherjee@gmail.com, tj@kernel.org,
        ubraun@linux.vnet.ibm.com, viresh.kum
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdJEAlh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 20:41:37 -0400
In-Reply-To: <1507159627-127660-5-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Wed,  4 Oct 2017 16:26:58 -0700

> This refactors the only users of init_timer_pinned() to use
> the new timer_setup() and from_timer(). Drops the definition of
> init_timer_pinned().
> 
> Cc: Chris Metcalf <cmetcalf@mellanox.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

For networking:

Acked-by: David S. Miller <davem@davemloft.net>
