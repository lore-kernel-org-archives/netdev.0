From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Wed, 30 Oct 2013 00:12:45 +0100
Message-ID: <1383088365.16822.22.camel@sakura.staff.proxad.net>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
	 <1382466229-15123-2-git-send-email-f.fainelli@gmail.com>
	 <5266D7D6.9000309@intel.com>
	 <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com>
	 <20131022202537.GA16336@hmsreliant.think-freely.org>
	 <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>
	 <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org>
	 <5267C6B9.4000704@mojatatu.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:60774 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182Ab3J2XTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 19:19:18 -0400
In-Reply-To: <5267C6B9.4000704@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2013-10-23 at 08:53 -0400, Jamal Hadi Salim wrote:

> So exposing the 5-8 ports as netdevs would be useful. Giving access to
> their stats through per-port netdevs etc. i.e a switch/bridge will 

While the intent is to make it look familiar to users, IMO this breaks
the rule of the least surprise.

>From a user POV, when you see a netdevice, you expect to be able to
receive or send packets from/to it. The ability to read stats/link is
only a secondary feature.

Wireless subsystem moved away from using dummy/additional netdevices
because it caused confusion.

multiqueue devices forced us to separate struct netdevice and struct
netdev_queue, maybe it's time for more surgery :)

-- 
Maxime
