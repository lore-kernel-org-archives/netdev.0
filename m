From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 30 Oct 2013 07:50:26 -0400
Message-ID: <5270F282.6000708@mojatatu.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>	 <1382466229-15123-2-git-send-email-f.fainelli@gmail.com>	 <5266D7D6.9000309@intel.com>	 <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com>	 <20131022202537.GA16336@hmsreliant.think-freely.org>	 <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>	 <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org>	 <5267C6B9.4000704@mojatatu.com> <1383088365.16822.22.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
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
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:57848 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab3J3Lu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 07:50:29 -0400
Received: by mail-ie0-f174.google.com with SMTP id qd12so2019915ieb.5
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 04:50:29 -0700 (PDT)
In-Reply-To: <1383088365.16822.22.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/13 19:12, Maxime Bizon wrote:

>
>  From a user POV, when you see a netdevice, you expect to be able to
> receive or send packets from/to it. The ability to read stats/link is
> only a secondary feature.
>

The important part is all the APIs stay consistent. I can use
same netlink calls. ifconfig works.
iproute2 works. People have written books on this stuff - we dont
have MCSE(Must Call Software Engineer) certification, but this is
as close as it gets. i.e the knowledge has been commoditized, even
my kid knows how to use these tools.

If i can get stats by doing ifconfig - that should provide illusion that
the netdevice is sending/receiving packets.

> Wireless subsystem moved away from using dummy/additional netdevices
> because it caused confusion.
>

This is a good arguement.
Can we hear a little more about this?

> multiqueue devices forced us to separate struct netdevice and struct
> netdev_queue, maybe it's time for more surgery :)
>

I think that would be a reasonable thing to do if it becomes necessary.

cheers,
jamal
