From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch iproute2 4/6] bridge/link: add new offload hwmode swdev
Date: Thu, 4 Dec 2014 12:55:54 -0800
Message-ID: <CAE4R7bBW4rvJeet_4XvO5KnEvyT=eyB4yOTUznUWpOBPrqXZUg@mail.gmail.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
	<1417683438-10935-5-git-send-email-jiri@resnulli.us>
	<54806042.5010007@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
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
	John Linville <linville@tuxdriver
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:43065 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbaLDUzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 15:55:55 -0500
Received: by mail-wg0-f54.google.com with SMTP id l2so23693823wgh.13
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 12:55:54 -0800 (PST)
In-Reply-To: <54806042.5010007@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2014 at 5:23 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/04/14 03:57, Jiri Pirko wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To support full-featured switch devices offloading bridge funtionality,
>> add new hwmode 'swdev'.  Like 'vepa' and 'veb', 'swdev' indicated bridge
>> port functionality is being offloaded to hardware.
>>
>
> Unhappy with the name swdev ..
> Ok, go ahead and beat up on me.

Lack of creativity, I know.  But, I doubt anyone is confused by the name.

Hopefully it's short-lived and replace with what Roopa comes up with
for switch port offload flag.
