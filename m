From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 14:39:01 -0800
Message-ID: <54750505.3060004@gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-3-git-send-email-jiri@resnulli.us> <20141125221417.GF3912@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:45040 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbaKYWjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:39:05 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so1449806pdb.32
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:39:04 -0800 (PST)
In-Reply-To: <20141125221417.GF3912@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/14 14:14, Thomas Graf wrote:
> On 11/25/14 at 11:28am, Jiri Pirko wrote:
>> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
>> u16 vid to drivers from there.
>>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> 
> I'm slightly confused ;-)
> 
> We both argued that parsing Netlink attributes in the drivers is wrong.
> What happened to the plan of renaming ndo_fdb_ to ndo_neigh_ and
> introducing a non-Netlink in-kernel API for advanced usage by swdev?
> 

Not sure I follow you here, the commit message says what it says it
does, are we looking at the same patch?
--
Florian
