From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Mon, 28 Oct 2013 18:29:39 -0400
Message-ID: <526EE553.5050408@mojatatu.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com> <CAGVrzcbmsMjB78_x8MoOf4C34OMMZ-+3RBbheA0bG=r5VUi4EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
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
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:61232 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab3J1W3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 18:29:48 -0400
Received: by mail-qc0-f181.google.com with SMTP id w4so4217921qcr.26
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 15:29:48 -0700 (PDT)
In-Reply-To: <CAGVrzcbmsMjB78_x8MoOf4C34OMMZ-+3RBbheA0bG=r5VUi4EQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/13 14:14, Florian Fainelli wrote:
> 2013/10/27 Jamal Hadi Salim <jhs@mojatatu.com>:
>> On 10/25/13 09:01, Felix Fietkau wrote:
>>>

>
> They are yes, the only "fancy" features these switches allow is
> basically to set a given's port vlan id, which is already a huge
> improvement compared to the vendor provided firmware.
>

Nice to know that you have something better than the vendor provided
stuff.

>
> The switch does have an address learning process which is usually not
> controlled by software at all, so yes, flooding is usually the way to
> get it to the CPU.
>

Ok.

> Which exact drivers are you refering to? If we are talking about DSA
> then yes, this is correct, but it is completely Ethernet MAC driver
> agnostic.
>

Sorry - cant point you to an exact one; one that i tried to convert to
NAPI and found these issues was from Netlogic (embedded 64 bit mips),
that i think now is in the kernel proper (and someone had converted to
NAPI as well). Let me get back to you with some sample examples..

> Why would we expose the hardware switch physical ports as netdevs if
> we cannot even any control over their data-path? Unlike these
> multiport NICs, the only traffic you see and you can control is the
> one from your CPU port.
>

Not necessarily for datapath, rather for control path. If i can
pull the stats, ifconfig up/down the port, set flow control
etc - then that is a  good reason to expose them.

>
> I do not really see how we could bend the existing interface (is it
> rtnetlink we are talking about or something else btw?) to expose these
> switches, maybe we could with iproute2, but still, the user-space
> interface/tool is far from being the problem here.
>

Look at the FDB API.
The user space interface as well as reusing kernel interfaces is my main
arguement.

> I don't think at any point in this discussion there was a mention that
> we do not want to change the user or kernel interface in OpenWrt
> because we have been using this for the past 5 years, on the contrary,
> if we are bringing this to a wide audience, this is to get some proper
> review and eventually change it.
>

Ok, sorry - I misinterpreted you and Felix. Like i said, if you gave me
that reason I would understand.

cheers,
jamal
