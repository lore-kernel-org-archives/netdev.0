From: Hau <hau@realtek.com>
Subject: RE: [PATCH net 1/3] r8169:fix nic sometimes doesn't work after changing the mac address.
Date: Sat, 27 Feb 2016 18:19:39 +0000
Message-ID: <80377ECBC5453840BA8C7155328B53770136B92F@RTITMBSV03.realtek.com.tw>
References: <1456476046-5436-1-git-send-email-hau@realtek.com>
 <1456476046-5436-2-git-send-email-hau@realtek.com>
 <20160226233158.GA26088@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160226233158.GA26088@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Instead of taking the device out of suspended mode to perform the required
> action, the driver is moving to a model where 1) said action may be
> scheduled to a later time - or result from past time work - and 2) rpm handler
> must handle a lot of pm unrelated work.
> 
> rtl8169_ethtool_ops.{get_wol, get_regs, get_settings} aren't even fixed yet
> (what about the .set_xyz handlers ?).
> 
> I can't help thinking that the driver should return to a state where it stupidly
> does what it is asked to. No software caching, plain device access, resume
> when needed, suspend as "suspend" instead of suspend as "anticipate
> whatever may happen to avoid waking up".
>

This rpm related patches just the workaround for the issues reported by end users.  As you say, the Linux kernel should handle these events when driver is in runtime suspend state.
 
------Please consider the environment before printing this e-mail.
