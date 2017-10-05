From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 10/13] timer: Remove expires and data arguments from DEFINE_TIMER
Date: Thu, 05 Oct 2017 09:54:33 +0300
Message-ID: <87d1625bkm.fsf@qca.qualcomm.com>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
        <1507159627-127660-11-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Gleixner <tglx@linutronix.de>,  Andrew Morton <akpm@linux-foundation.org>,  Arnd Bergmann <arnd@arndb.de>,  Benjamin Herrenschmidt <benh@kernel.crashing.org>,  Chris Metcalf <cmetcalf@mellanox.com>,  Geert Uytterhoeven <geert@linux-m68k.org>,  Greg Kroah-Hartman <gregkh@linuxfoundation.org>,  Guenter Roeck <linux@roeck-us.net>,  Harish Patil <harish.patil@cavium.com>,  Heiko Carstens <heiko.carstens@de.ibm.com>,  "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,  John Stultz <john.stultz@linaro.org>,  Julian Wiedmann <jwi@linux.vnet.ibm.com>,  Lai Jiangshan <jiangshanlai@gmail.com>,  Len Brown <len.brown@intel.com>,  Manish Chopra <manish.chopra@cavium.com>,  Mark Gross <mark.gross@intel.com>,  "Martin K. Petersen" <martin.petersen@oracle.com>,  Martin Schwidefsky <schwidefs
 ky@de.ibm.com>,  Michael Ellerman <mpe@ellerman.id.au>,  Michael Reed <mdr@sgi.com>,  netdev@vger.kern
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1507159627-127660-11-git-send-email-keescook@chromium.org> (Kees
        Cook's message of "Wed, 4 Oct 2017 16:27:04 -0700")
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> writes:

> Drop the arguments from the macro and adjust all callers with the
> following script:
>
>   perl -pi -e 's/DEFINE_TIMER\((.*), 0, 0\);/DEFINE_TIMER($1);/g;' \
>     $(git grep DEFINE_TIMER | cut -d: -f1 | sort -u | grep -v timer.h)
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org> # for m68k parts

[...]

>  drivers/net/wireless/atmel/at76c50x-usb.c | 2 +-

For wireless:

Acked-by: Kalle Valo <kvalo@codeaurora.org>

-- 
Kalle Valo
