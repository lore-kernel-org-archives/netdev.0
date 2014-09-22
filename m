From: Tom Herbert <therbert@google.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Mon, 22 Sep 2014 16:07:42 -0700
Message-ID: <CA+mtBx94TrLzQrZDo58d9ktma3ZioOpO=2FAODMRoiyiuYkQ9Q@mail.gmail.com>
References: <20140919154946.GH1980@nanopsycho.orion>
	<541C6E6D.9000109@mojatatu.com>
	<541CAA3C.5080105@intel.com>
	<20140920081426.GE1821@nanopsycho.orion>
	<20140920105354.GA29419@casper.infradead.org>
	<CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
	<20140922081341.GA20905@casper.infradead.org>
	<CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
	<20140922221727.GA4708@casper.infradead.org>
	<CA+mtBx9ZVQ5r5Hzy9-uEnk+iu+HKkOP4+VANC06Xf8VvTxktwQ@mail.gmail.com>
	<20140922225305.GB4708@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:52240 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbaIVXHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 19:07:43 -0400
Received: by mail-ig0-f180.google.com with SMTP id a13so3658234igq.1
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 16:07:42 -0700 (PDT)
In-Reply-To: <20140922225305.GB4708@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2014 at 3:53 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/22/14 at 03:40pm, Tom Herbert wrote:
>> On Mon, Sep 22, 2014 at 3:17 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> > What makes stateful offload interesting to me is that the final
>> > desintation of a packet is known at RX and can be redirected to a
>> > queue or VF. This allows to build packet batches on shared pages
>> > while preserving the securiy model.
>> >
>> How is this different from what rx-filtering already does?
>
> Without stateful offload I can't know where the packet is destined
> to until after I've allocated an skb and parsed the packet in
> software. I might be missing what you refer to here specifically.

n-tuple filtering in as exposed by ethtool.
