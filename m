From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RESEND PATCH -net] cpsw/netcp: work around reverse cpts dependency
Date: Fri, 17 Mar 2017 11:00:42 +0100
Message-ID: <CAK8P3a23WDCGeWQU-9XukmrfA7WJDyidj9ffJmTTduvGZ9opGQ@mail.gmail.com>
References: <20170313165927.1389014-1-arnd@arndb.de> <20170316.201323.374866113649500200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>, richardcochran@gmail.com,
        WingMan Kwok <w-kwok2@ti.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316.201323.374866113649500200.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 17, 2017 at 4:13 AM, David Miller <davem@davemloft.net> wrote:
>
> I'm fine with this change, but please keep the user visible Kconfig
> symbol name the same, use the new name for the internal one.

Yes, makes snese.

> I know that this means you have to make more changes elsewhere in
> order to accomplish this.

It turned out to require just one extra change line, as the other references
work either way (they use IS_ENABLED()). I'm running a little more build
tests and will then submit the new version.

     Arnd
