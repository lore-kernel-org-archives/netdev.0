From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 15:50:46 -0700
Message-ID: <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
	<1411134590-4586-9-git-send-email-jiri@resnulli.us>
	<541C4AFC.8060500@mojatatu.com>
	<20140919154946.GH1980@nanopsycho.orion>
	<541C6E6D.9000109@mojatatu.com>
	<541CAA3C.5080105@intel.com>
	<20140920081426.GE1821@nanopsycho.orion>
	<20140920105354.GA29419@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
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
	Andy Zhou <azhou@nicira.com>, ben@decadent.org.uk,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	"dev@openvswitch.org" <dev@openvswitch.o
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:32790 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaITWur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 18:50:47 -0400
Received: by mail-qa0-f46.google.com with SMTP id f12so3999552qad.19
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 15:50:47 -0700 (PDT)
In-Reply-To: <20140920105354.GA29419@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 20, 2014 at 3:53 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/20/14 at 10:14am, Jiri Pirko wrote:
>> Sat, Sep 20, 2014 at 12:12:12AM CEST, john.r.fastabend@intel.com wrote:
>> >I was considering a slightly different approach where the
>> >device would report via netlink the fields/actions it
>> >supported rather than creating pre-defined enums for every
>> >possible key.
>> >
>> >I already need to have an API to report fields/matches
>> >that are being supported why not have the device report
>> >the headers as header fields (len, offset) and the
>> >associated parse graph the hardware uses? Vendors should
>> >have this already to describe/design their real hardware.
>>
>> Hmm, let me think about this a bit more. I will try to figure out how to
>> handle that. Sound logic though. Will try to incorporate the idea in the
>> patchset.
>
> I think this is the right track.

I agree with John and Thomas here.
I think HW should not be limited by SW abstractions whether
these abstractions are called flows, n-tuples, bridge or else.
Really looking forward to see "device reporting the headers as
header fields (len, offset) and the associated parse graph"
as the first step.

Another topic that this discussion didn't cover yet is how this
all connects to tunnels and what is 'tunnel offloading'.
imo flow offloading by itself serves only academic interest.
