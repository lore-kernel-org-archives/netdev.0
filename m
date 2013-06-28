From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] Set the correct RTNL family for multicast netconf messages
Date: Fri, 28 Jun 2013 12:13:55 +0200
Message-ID: <51CD61E3.5040104@6wind.com>
References: <1372376687.21767.10.camel@imac-linux.luckyscavenger.com> <20130628012307.GB15799@order.stressinduktion.org> <20130627183342.4b9c5598@nehalam.linuxnetplumber.net> <20130628015121.GC15799@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stephen Hemminger <stephen@networkplumber.org>,
	Sven-Thorsten Dietrich <sven@vyatta.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mike Davison <Mike.Davison@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130628015121.GC15799@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 28/06/2013 03:51, Hannes Frederic Sowa a =C3=A9crit :
> On Thu, Jun 27, 2013 at 06:33:42PM -0700, Stephen Hemminger wrote:
>> On Fri, 28 Jun 2013 03:23:07 +0200
>> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>>> Hm, are you sure? NETCONFA_MC_FORWARDING is of type RTM_NEWNETCONF
>>> and expects ncm_family to be either AF_INET or AF_INET6 (at least i=
n
>>> iproute2/ipmonitor.c).
>>>
>>
>> I agree with Sven on this, looks like the recent addition of netconf
>> configuration to netlink didn't embrace how multicast is handled in =
kernel.
>>
>> Multicast forwarding is a routing related configuration value.
>> All the multicast routing events come in as special family RTNL_FAMI=
LY_IPMR
>> (see net/ipv4/ipmr.c function ipmr_fill_route). I would expect that =
multicast
>> routing daemons would like to be able to use special family to liste=
n for
>> all multicast related changes (and not see non-multicast events).
>>
>>
>> Minor nit: the patch is formatted incorrectly (case should line up w=
ith switch).
>
> Yes, this seems reasonable but would need a small update to ipnetconf=
=2Ec, too.
I also agree with Sven and Stephen.

Note also that the Signed-off-by line is missing in the commit log.

Sven, can you take care of the iproute2 patch? If not, let me know so I=
 can do it.


Thank you,
Nicolas
