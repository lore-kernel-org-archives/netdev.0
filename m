From: "Gross, Mark" <mark.gross@intel.com>
Subject: RE: [PATCH 07/13] timer: Remove last user of TIMER_INITIALIZER
Date: Thu, 5 Oct 2017 22:39:51 +0000
Message-ID: <BD75D217E5BAC84080F8EFB2582976379E85363A@ORSMSX112.amr.corp.intel.com>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
 <1507159627-127660-8-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        "Guenter Roeck" <linux@roeck-us.net>,
        Harish Patil <harish.patil@cavium.com>,
        "Heiko Carstens" <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        "Julian Wiedmann" <jwi@linux.vnet.ibm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        "Brown, Len" <len.brown@intel.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com
To: Kees Cook <keescook@chromium.org>,
        Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1507159627-127660-8-git-send-email-keescook@chromium.org>
Content-Language: en-US
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

Acked-by: mark gross <mark.gross@intel.com>

--mark

> -----Original Message-----
> From: Kees Cook [mailto:keescook@chromium.org]
> Sent: Wednesday, October 4, 2017 4:27 PM
> To: Thomas Gleixner <tglx@linutronix.de>
> Cc: Kees Cook <keescook@chromium.org>; Arnd Bergmann <arnd@arndb.de>;
> Greg Kroah-Hartman <gregkh@linuxfoundation.org>; Gross, Mark
> <mark.gross@intel.com>; Andrew Morton <akpm@linux-foundation.org>;
> Benjamin Herrenschmidt <benh@kernel.crashing.org>; Chris Metcalf
> <cmetcalf@mellanox.com>; Geert Uytterhoeven <geert@linux-m68k.org>;
> Guenter Roeck <linux@roeck-us.net>; Harish Patil <harish.patil@cavium.com>;
> Heiko Carstens <heiko.carstens@de.ibm.com>; James E.J. Bottomley
> <jejb@linux.vnet.ibm.com>; John Stultz <john.stultz@linaro.org>; Julian
> Wiedmann <jwi@linux.vnet.ibm.com>; Kalle Valo <kvalo@qca.qualcomm.com>;
> Lai Jiangshan <jiangshanlai@gmail.com>; Brown, Len <len.brown@intel.com>;
> Manish Chopra <manish.chopra@cavium.com>; Martin K. Petersen
> <martin.petersen@oracle.com>; Martin Schwidefsky
> <schwidefsky@de.ibm.com>; Michael Ellerman <mpe@ellerman.id.au>; Michael
> Reed <mdr@sgi.com>; netdev@vger.kernel.org; Oleg Nesterov
> <oleg@redhat.com>; Paul Mackerras <paulus@samba.org>; Pavel Machek
> <pavel@ucw.cz>; Petr Mladek <pmladek@suse.com>; Rafael J. Wysocki
> <rjw@rjwysocki.net>; Ralf Baechle <ralf@linux-mips.org>; Sebastian Reichel
> <sre@kernel.org>; Stefan Richter <stefanr@s5r6.in-berlin.de>; Stephen Boyd
> <sboyd@codeaurora.org>; Sudip Mukherjee <sudipm.mukherjee@gmail.com>;
> Tejun Heo <tj@kernel.org>; Ursula Braun <ubraun@linux.vnet.ibm.com>; Viresh
> Kumar <viresh.kumar@linaro.org>; Wim Van Sebroeck <wim@iguana.be>;
> linux1394-devel@lists.sourceforge.net; linux-mips@linux-mips.org; linux-
> pm@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; linux-
> s390@vger.kernel.org; linux-scsi@vger.kernel.org; linux-
> watchdog@vger.kernel.org; linux-wireless@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: [PATCH 07/13] timer: Remove last user of TIMER_INITIALIZER
> 
> Drops the last user of TIMER_INITIALIZER and adapts timer.h to use the internal
> version.
> 
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Mark Gross <mark.gross@intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  drivers/char/tlclk.c  | 12 +++++-------  include/linux/timer.h |  2 +-
>  2 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/char/tlclk.c b/drivers/char/tlclk.c index
> 6210bff46341..8eeb4190207d 100644
> --- a/drivers/char/tlclk.c
> +++ b/drivers/char/tlclk.c
> @@ -184,9 +184,8 @@ static unsigned int telclk_interrupt;
>  static int int_events;		/* Event that generate a interrupt */
>  static int got_event;		/* if events processing have been done */
> 
> -static void switchover_timeout(unsigned long data); -static struct timer_list
> switchover_timer =
> -	TIMER_INITIALIZER(switchover_timeout , 0, 0);
> +static void switchover_timeout(struct timer_list *t); static struct
> +timer_list switchover_timer;
>  static unsigned long tlclk_timer_data;
> 
>  static struct tlclk_alarms *alarm_events; @@ -805,7 +804,7 @@ static int
> __init tlclk_init(void)
>  		goto out3;
>  	}
> 
> -	init_timer(&switchover_timer);
> +	timer_setup(&switchover_timer, switchover_timeout, 0);
> 
>  	ret = misc_register(&tlclk_miscdev);
>  	if (ret < 0) {
> @@ -855,9 +854,9 @@ static void __exit tlclk_cleanup(void)
> 
>  }
> 
> -static void switchover_timeout(unsigned long data)
> +static void switchover_timeout(struct timer_list *unused)
>  {
> -	unsigned long flags = *(unsigned long *) data;
> +	unsigned long flags = tlclk_timer_data;
> 
>  	if ((flags & 1)) {
>  		if ((inb(TLCLK_REG1) & 0x08) != (flags & 0x08)) @@ -922,7
> +921,6 @@ static irqreturn_t tlclk_interrupt(int irq, void *dev_id)
>  		/* TIMEOUT in ~10ms */
>  		switchover_timer.expires = jiffies + msecs_to_jiffies(10);
>  		tlclk_timer_data = inb(TLCLK_REG1);
> -		switchover_timer.data = (unsigned long) &tlclk_timer_data;
>  		mod_timer(&switchover_timer, switchover_timer.expires);
>  	} else {
>  		got_event = 1;
> diff --git a/include/linux/timer.h b/include/linux/timer.h index
> 10cc45ca5803..4f7476e4a727 100644
> --- a/include/linux/timer.h
> +++ b/include/linux/timer.h
> @@ -87,7 +87,7 @@ struct timer_list {
> 
>  #define DEFINE_TIMER(_name, _function, _expires, _data)		\
>  	struct timer_list _name =				\
> -		TIMER_INITIALIZER(_function, _expires, _data)
> +		__TIMER_INITIALIZER(_function, _expires, _data, 0)
> 
>  void init_timer_key(struct timer_list *timer, unsigned int flags,
>  		    const char *name, struct lock_class_key *key);
> --
> 2.7.4
