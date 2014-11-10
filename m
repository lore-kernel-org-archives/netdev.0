From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Mon, 10 Nov 2014 14:27:14 -0500
Message-ID: <54611192.5080606@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-11-git-send-email-jiri@resnulli.us> <546036A3.3010404@mojatatu.com> <CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com> <5460AF22.2040701@mojatatu.com> <5460E3D5.3000104@cumulusnetworks.com> <CAE4R7bARr8_=sS+6aezKDX0FfERUj8AD6eOGONKAeRd-g+9nDA@mail.gmail.com> <5461058F.1020709@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
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
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:40312 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbaKJT1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:27:18 -0500
Received: by mail-ig0-f170.google.com with SMTP id h15so16234930igd.1
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 11:27:17 -0800 (PST)
In-Reply-To: <5461058F.1020709@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 13:35, Roopa Prabhu wrote:
> On 11/10/14, 9:36 AM, Scott Feldman wrote:
>> On Mon, Nov 10, 2014 at 6:12 AM, Roopa Prabhu
>> <roopa@cumulusnetworks.com> wrote:
>>> On 11/10/14, 4:27 AM, Jamal Hadi Salim wrote:
>>>> On 11/10/14 03:46, Scott Feldman wrote:
>
> yes it is, But if i remember correctly, the api (ndo op) could indicate
> offload to hw (or nic in this case)
> by giving 'self'. And in those cases the netdev nic port represents the
> switch.
>   (Will be nice to check and confirm this though).

No, you are correct. You select to add to the bridge fdb or/and via
the underlying brport fdb.

cheers,
jamal
