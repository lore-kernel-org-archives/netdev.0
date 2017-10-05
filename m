From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13] timer: Remove expires and data arguments from
 DEFINE_TIMER
Date: Wed, 04 Oct 2017 17:40:55 -0700 (PDT)
Message-ID: <20171004.174055.1185097411151057568.davem@davemloft.net>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
        <1507159627-127660-11-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, akpm@linux-foundation.org, arnd@arndb.de,
        benh@kernel.crashing.org, cmetcalf@mellanox.com,
        geert@linux-m68k.org, gregkh@linuxfoundation.org,
        linux@roeck-us.net, harish.patil@cavium.com,
        heiko.carstens@de.ibm.com, jejb@linux.vnet.ibm.com,
        john.stultz@linaro.org, jwi@linux.vnet.ibm.com,
        kvalo@qca.qualcomm.com, jiangshanlai@gmail.com,
        len.brown@intel.com, manish.chopra@cavium.com,
        mark.gross@intel.com, martin.petersen@oracle.com,
        schwidefsky@de.ibm.com, mpe@ellerman.id.au, mdr@sgi.com,
        netdev@vger.kernel.org, oleg@redhat.com, paulus@samba.org,
        pavel@ucw.cz, pmladek@suse.com, rjw@rjwysocki.net,
        ralf@linux-mips.org, sre@kernel.org, stefanr@s5r6.in-berlin.de,
        sboyd@codeaurora.org, sudipm.mukherjee@gmail.com, tj@kernel.org,
        ubraun@linux.vnet.ibm.com, viresh.kum
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507159627-127660-11-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed,  4 Oct 2017 16:27:04 -0700

> Drop the arguments from the macro and adjust all callers with the
> following script:
> 
>   perl -pi -e 's/DEFINE_TIMER\((.*), 0, 0\);/DEFINE_TIMER($1);/g;' \
>     $(git grep DEFINE_TIMER | cut -d: -f1 | sort -u | grep -v timer.h)
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org> # for m68k parts

For networking:

Acked-by: David S. Miller <davem@davemloft.net>
