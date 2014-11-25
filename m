From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 16/17] bridge: add brport flags to dflt bridge_getlink
Date: Tue, 25 Nov 2014 09:02:51 -0800
Message-ID: <CAE4R7bCTVPimZ3_0sXCh_zF+fiOLF9jTZ4neTGQwaBmNWYn2BQ@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-17-git-send-email-jiri@resnulli.us>
	<5474A992.5010305@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	Aviad Raveh <aviadr@mellanox.com>, nbd@openwrt.org,
	Alexei Starovoitov <alexei.
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:63856 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaKYRCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:02:52 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so9801952wib.10
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:02:51 -0800 (PST)
In-Reply-To: <5474A992.5010305@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 8:08 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 11/25/14 05:28, Jiri Pirko wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To allow brport device to return current brport flags set on port.  Add
>> returned flags to nested IFLA_PROTINFO netlink msg built in dflt getlink.
>> With this change, netlink msg returned for bridge_getlink contains the
>> port's
>> offloaded flag settings (the port's SELF settings).
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>
> Not sure i followed this. VEPA etc are offload modes, no?
> I like the harvesting from netlink->internal format but
> not sure i followed the rest: VEPA etc are offload modes, no?

VEPA etc are offload modes.

> cheers,
> jamal
