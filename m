From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices support
Date: Tue, 25 Nov 2014 18:18:17 -1000
Message-ID: <CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-5-git-send-email-jiri@resnulli.us>
	<5474A567.4040401@mojatatu.com>
	<20141125164954.GJ1971@nanopsycho.orion>
	<5474B795.3080204@mojatatu.com>
	<20141125215402.GA3912@casper.infradead.org>
	<54754A10.6020601@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
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
	John Linville <linville@tuxdriver
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:59520 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbaKZEST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 23:18:19 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so11193291wid.9
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 20:18:17 -0800 (PST)
In-Reply-To: <54754A10.6020601@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 5:33 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 11/25/14 16:54, Thomas Graf wrote:
>>
>> On 11/25/14 at 12:08pm, Jamal Hadi Salim wrote:
>
>
>> It would definitely help if you could expose some more details on the
>> "some network processor" you have. We're all very eager ;-)
>>
>
> Well, this thing doesnt run ovs ;-> (/me runs). If you come
> to netdev i may let you play with it ;-> Its a humongous device
> (think multi 100G ports).
>
> On a serious note: Even if you took what Simon/Netronome has
> (yes, I know they use ovs;->) - there is really no need for a switch
> abstraction *at all* if all you want to is hang a packet
> processing graph that ingresses at a port and egress at another port.
> As you know, Linux supports it just fine with tc.

You have a pointer to the kernel driver for that HW?  Can you show how
you're using Linux tc netlink msg in kernel to program HW?  I'd like
to see the in-kernel API.
