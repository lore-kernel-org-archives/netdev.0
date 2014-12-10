From: Hau <hau@realtek.com>
Subject: RE: [PATCH net-next 0/9] r8169:update hardware ephy parameter
Date: Wed, 10 Dec 2014 07:17:04 +0000
Message-ID: <80377ECBC5453840BA8C7155328B537701085AD8@RTITMBSV03.realtek.com.tw>
References: <1418143563-7652-1-git-send-email-hau@realtek.com>
 <20141209.183549.1930188640715074097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209.183549.1930188640715074097.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, December 10, 2014 7:36 AM
> To: Hau
> Cc: netdev@vger.kernel.org; nic_swsd; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next 0/9] r8169:update hardware ephy parameter
> 
> From: Chunhao Lin <hau@realtek.com>
> Date: Wed, 10 Dec 2014 00:45:54 +0800
> 
> > Update hardware ephy parameter to improve pcie compatibility.
> 
> This really doesn't tell me anything, I really dislike patch series like this one.
> 
> All of the programming is magic values to magic offsets.
> 
> You aren't even trying to describe in the commit log message exactly what
> kind of settings are being changed, and exactly how those changes achieve
> the stated goal.
> 
> Furthermore, the commit description makes no sense at all to me.
> 
> How can programming the ethernet MAC PHY have any influence on PCI-E
> bus compatability?  Or are you programming the PCI bus interface's PHY?
> 
> In what way are you adjusting which settings and in what way do those
> adjustments help improve PCI-E bus behavior?
> 
> You absolutely must describe exactly what the new programming is actually
> doing, precisely, and in detail.  I want to know if some kind of timings are
> being adjusted, and in what way.
> Are some fifo limits being changes?  If so, in what way, and why does that
> help.
> 
> You have to describe what you are doing. Short and non-informative commit
> log messages alongside random changes to undocumented magic constant
> registers is simply unacceptable.
> 

These series patch is an alignment with our latest hardware pcie ephy parameters. I will try to explain more on my next patch.

Thanks.
