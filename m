From: Borislav Petkov <bp@alien8.de>
Subject: Re: New issues in 2.6.35-rc{1,2}
Date: Mon, 14 Jun 2010 18:43:20 +0200
Message-ID: <20100614164320.GA4392@a1.tnic>
References: <20100614161904.GE31910@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Nico Schottelius <nico-linux-20100614@schottelius.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100614161904.GE31910@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nico Schottelius <nico-linux-20100614@schottelius.org>
Date: Mon, Jun 14, 2010 at 06:19:04PM +0200

Ccing netdev.

> Hey devs!
> 
> In both of these versions, the update of the carrier flag seems
> to be "different" than before (linux-2.6.34-08528-gb3f2f6c):
> 
> wlan0 (iwlagn) does not recognize it's disconnected
> and eth0 (e1000e) does only react correctly after I restarted
> dhcpcd (isc):
> 
> [11:20] kr:pm# dhcpcd eth0 
> dhcpcd: version 5.2.2 starting
> dhcpcd: eth0: waiting for carrier
> ^Cdhcpcd: received SIGINT, stopping
> dhcpcd: eth0: removing interface
> [11:20] kr:pm# dhcpcd eth0
> dhcpcd: version 5.2.2 starting
> dhcpcd: eth0: broadcasting for a lease
> dhcpcd: eth0: offered 129.132.102.115 from 129.132.65.12
> dhcpcd: eth0: ignoring offer of 129.132.102.115 from 129.132.57.97
> dhcpcd: eth0: acknowledged 129.132.102.115 from 129.132.65.12
> dhcpcd: eth0: checking for 129.132.102.115
> dhcpcd: eth0: leased 129.132.102.115 for 86400 seconds
> dhcpcd: forking to background
> 
> It's known that iwlagn has problems after suspend/resume,
> but new is that both nics do not notify dhcpcd that the link
> has gone. I'm not sure what / where broke here, just see that
> dhcpcd noticed it before and now doesn't anymore.

Had the same dhcpcd issue here both with e1000e and bnx2 and definitely
after the .35 merge window. dhclient doesn't seem affected.

-- 
Regards/Gruss,
Boris.
