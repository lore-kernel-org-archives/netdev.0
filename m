From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Mon, 10 Nov 2014 14:25:31 -0500
Message-ID: <5461112B.4020006@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>	<1415530280-9190-11-git-send-email-jiri@resnulli.us>	<546036A3.3010404@mojatatu.com>	<CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com>	<5460AF22.2040701@mojatatu.com>	<5460E3D5.3000104@cumulusnetworks.com> <CAE4R7bARr8_=sS+6aezKDX0FfERUj8AD6eOGONKAeRd-g+9nDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
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
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Neil Jerram <Neil.Jerram@metaswitch.com>, ronye@me
To: Scott Feldman <sfeldma@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:53043 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbaKJTZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:25:34 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so9900173ieb.18
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 11:25:34 -0800 (PST)
In-Reply-To: <CAE4R7bARr8_=sS+6aezKDX0FfERUj8AD6eOGONKAeRd-g+9nDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 12:36, Scott Feldman wrote:
> On Mon, Nov 10, 2014 at 6:12 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> Per-port gives more flexibility, and it looks like we can extend
> existing IFLA_BRPORT_LEARNING without much trouble.
>

I am thinking per port as well...
So we have hardware and/or software selection of per port:
fdb flooding control, fdb learning control,
stp controls, multicast controls
some of those weird vepa controls

This is why i thought all these could use a bit representation each.
You have 32 bit flags and 32 bit selector.

cheers,
jamal
