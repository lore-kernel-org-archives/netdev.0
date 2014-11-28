From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Fri, 28 Nov 2014 08:13:06 -0500
Message-ID: <547874E2.7010200@mojatatu.com>
References: <54754A10.6020601@mojatatu.com> <CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com> <5475BB53.3070200@mojatatu.com> <20141126160859.GB13786@casper.infradead.org> <54760939.8050805@mojatatu.com> <20141126175944.GW1875@nanopsycho.orion> <20141126215034.GA32174@casper.infradead.org> <547662F4.3060408@mojatatu.com> <20141127130345.GB27041@casper.infradead.org> <547727F0.7020105@mojatatu.com> <20141127135050.GD1877@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdr
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:60166 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaK1NNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:13:10 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so5984220iec.22
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:13:10 -0800 (PST)
In-Reply-To: <20141127135050.GD1877@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/14 08:50, Jiri Pirko wrote:

> $ git grep offload net
> Wouldn't it be confusing to add this another different "offload". That's
> just confusing.
>
> I still like "switch" the best. If it passes packets around, it's a
> "switch", +-. Everybody understand what's going on if you use "switch".
> If you use "offload", everybody is confused...
>

Those are all *legitimate offloads* ;->
The macvlan one looks a little creepy. Perhaps we could eventually
merge all that stuff together with this effort.

cheers,
jamal
