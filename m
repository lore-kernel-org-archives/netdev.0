From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Thu, 27 Nov 2014 14:50:50 +0100
Message-ID: <20141127135050.GD1877@nanopsycho.orion>
References: <54754A10.6020601@mojatatu.com>
 <CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com>
 <5475BB53.3070200@mojatatu.com>
 <20141126160859.GB13786@casper.infradead.org>
 <54760939.8050805@mojatatu.com>
 <20141126175944.GW1875@nanopsycho.orion>
 <20141126215034.GA32174@casper.infradead.org>
 <547662F4.3060408@mojatatu.com>
 <20141127130345.GB27041@casper.infradead.org>
 <547727F0.7020105@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:48637 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbaK0Nux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 08:50:53 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so15813093wiw.13
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 05:50:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547727F0.7020105@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 27, 2014 at 02:32:32PM CET, jhs@mojatatu.com wrote:
>On 11/27/14 08:03, Thomas Graf wrote:
>
>>So what is your name suggestion?
>>
>
>I would have gone for _offload_ either as a prefix or suffix
>somewhere.

$ git grep offload net
Wouldn't it be confusing to add this another different "offload". That's
just confusing.

I still like "switch" the best. If it passes packets around, it's a
"switch", +-. Everybody understand what's going on if you use "switch".
If you use "offload", everybody is confused...


>
>cheers,
>jamal
