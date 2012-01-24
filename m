From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Tue, 24 Jan 2012 00:57:36 -0200
Message-ID: <CAOMZO5A9qpgAhL9NZXL3uYqSVjDPchdmBMySzjD=uenndjY4bw@mail.gmail.com>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com>
	<CAOMZO5BQhcxViN3KnjhzF9hL1w04egkmb9njc7sDUB0GFdgBog@mail.gmail.com>
	<20120106050355.GA7633@kroah.com>
	<201201061200.44183.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, gwingerde@gmail.com,
	larry.finger@lwfinger.net, davem@davemloft.net,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Arnd Bergmann <arnd@arndb.de>, Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201201061200.44183.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

On Fri, Jan 6, 2012 at 10:00 AM, Arnd Bergmann <arnd@arndb.de> wrote:

> I think that is true for the majority of stuff we have under drivers/misc
> anyway. I had done the same patch that Fabio sent a couple of months ago
> but then forgot about it, so here is a wholehearted
>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
>
> for the new patch. It fixes a real problem, and we applied a similar patch
> in drivers/mfd as 8a0a8e8e already. We probably still want to find a better
> home for drivers that frequently get selected by other subsystems as you
> said, but that is an independent issue. I don't see why anyone would
> need a way to disable all MISC drivers at once, when the only thing that
> (in theory) connects them is that they are all different from everything
> else.

Do you have any objections about this patch?

Thanks,

Fabio Estevam
