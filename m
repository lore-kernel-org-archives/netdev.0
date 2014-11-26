From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for
 ndo_fdb_add/ndo_fdb_del
Date: Wed, 26 Nov 2014 08:54:49 +0100
Message-ID: <20141126075449.GA1875@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-3-git-send-email-jiri@resnulli.us>
 <20141125221417.GF3912@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:55054 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbaKZHyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 02:54:52 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so3977186wiw.9
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 23:54:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141125221417.GF3912@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 25, 2014 at 11:14:17PM CET, tgraf@suug.ch wrote:
>On 11/25/14 at 11:28am, Jiri Pirko wrote:
>> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
>> u16 vid to drivers from there.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>I'm slightly confused ;-)
>
>We both argued that parsing Netlink attributes in the drivers is wrong.
>What happened to the plan of renaming ndo_fdb_ to ndo_neigh_ and
>introducing a non-Netlink in-kernel API for advanced usage by swdev?

Well the thing is that at the moment, it is not needed to call ndo_fdb_*
from inside the kernel. So the whole plan does not have to happen now.
Plus I saw the patches (Scott sent me) and I believe that they are
unnecessary complex. We can do this later if needed. Now, I would like
to stick with what we have so far, keep things simple.
