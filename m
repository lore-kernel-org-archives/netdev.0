From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 17/17] rocker: add ndo_bridge_setlnk/getlink
 support for learning policy
Date: Tue, 25 Nov 2014 08:55:34 -1000
Message-ID: <CAE4R7bBNvXFYZiOH+cNm_o6PyyQfCXAWrxU7tJzo+pJ+QQSXGg@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-18-git-send-email-jiri@resnulli.us>
	<5474A9A4.9070905@mojatatu.com>
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
Received: from mail-wi0-f171.google.com ([209.85.212.171]:64252 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaKYSzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:55:35 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so10128995wib.10
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 10:55:34 -0800 (PST)
In-Reply-To: <5474A9A4.9070905@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 6:09 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 11/25/14 05:28, Jiri Pirko wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Rocker ports will use new "swdev" hwmode for bridge port offload policy.
>> Current supported policy settings are BR_LEARNING and BR_LEARNING_SYNC.
>> User can turn on/off device port FDB learning and syncing to bridge.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>
> as previous comments - please submit rocker separately

I disagree.  API changes need a reference implementation to show usage
and for testing.  If you have have an alternate switch implementation
that achieves the same goal, bring it forward.

> cheers,
> jamal
