From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Mon, 13 Sep 2010 10:09:15 -0400
Message-ID: <4C8E308B.7020003@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <4C8950D4.9060102@criticallink.com> <201009101823.52755.caglarakyuz@gmail.com> <201009111154.42171.caglarakyuz@gmail.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Michael Williamson <michael.williamson@criticallink.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Caglar Akyuz <caglarakyuz@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <201009111154.42171.caglarakyuz@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Caglar,

[...]
> Unfortunately emac driver is not stable after this series. I face lock-ups 
> time to time, followed by attached kernel trace.

Could you elaborate on your test scenario so that I can try and
reproduce the problem at my end?  Also, did you have the contents of my
commit stack in this particular kernel build?

Assuming that the DMA got stuck at some point leading up to the transmit
timeout, any ideas as to why a host error was not thrown?  To help
debug, I'll post out a set of patches that dump out the MAC (and DMA)
registers on timeout.  That should give us some visibility into the problem.

> [ 1651.440000] nfs: server 192.168.2.34 not responding, still trying
> [ 1859.010000] ------------[ cut here ]------------
> [ 1859.010000] WARNING: at net/sched/sch_generic.c:258 
> dev_watchdog+0x184/0x294()
> [ 1859.020000] NETDEV WATCHDOG: eth0 (davinci_emac): transmit queue 0 timed 
> out
[...]

Regards
Cyril.
