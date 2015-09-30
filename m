From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 0/5] y2038 conversion for ntp/pps and sfc driver
Date: Wed, 30 Sep 2015 09:27:01 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509300926050.4500@nanos>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de> <20150929.210612.769591464523592086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: arnd@arndb.de, y2038@lists.linaro.org, john.stultz@linaro.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	giometti@enneenne.com, linux-net-drivers@solarflare.com,
	sshah@solarflare.com, richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150929.210612.769591464523592086.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Sep 2015, David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Mon, 28 Sep 2015 22:21:27 +0200
> 
> > When trying to build a kernel with time_t commented out, I found that
> > the ntp subsystem still relies on timespec for its pps handling.
> > 
> > This series addresses this and converts all the code to use timespec64
> > instead, step by step. There is one device driver that interacts with
> > this code directly (rather than only through the ptp subsystem), so
> > I have to convert that driver at the same time.
> > 
> > The patches should ideally stay together as a series, but they do
> > span multiple subsystems, so I'm also looking for the right person
> > to merge them.
> 
> I'm happy with this going via a tree other than mine, and for the

I think it should go via John Stultz timekeeping tree. 

Thanks,

	tglx
