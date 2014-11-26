From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Tue, 25 Nov 2014 22:33:36 -0500
Message-ID: <54754A10.6020601@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-5-git-send-email-jiri@resnulli.us> <5474A567.4040401@mojatatu.com> <20141125164954.GJ1971@nanopsycho.orion> <5474B795.3080204@mojatatu.com> <20141125215402.GA3912@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34473 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbaKZDdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 22:33:43 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so1940873iec.1
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 19:33:42 -0800 (PST)
In-Reply-To: <20141125215402.GA3912@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 16:54, Thomas Graf wrote:
> On 11/25/14 at 12:08pm, Jamal Hadi Salim wrote:

> It would definitely help if you could expose some more details on the
> "some network processor" you have. We're all very eager ;-)
>

Well, this thing doesnt run ovs ;-> (/me runs). If you come
to netdev i may let you play with it ;-> Its a humongous device
(think multi 100G ports).

On a serious note: Even if you took what Simon/Netronome has
(yes, I know they use ovs;->) - there is really no need for a switch
abstraction *at all* if all you want to is hang a packet
processing graph that ingresses at a port and egress at another port.
As you know, Linux supports it just fine with tc.

> I'm with Jiri but I agree it's not a perfect fit. I doubt there is but
> if you can come up with something that fits better I'm open to it.
>
> I considered "dataplane" or "dp" for a bit but it's quite generic as
> well.
>

The purpose is to offload. I think any name would be better than
mapping it to a specific abstraction called "switch". Especially
if it is hanging off a port and there is no switch in the pipeline.

cheers,
jamal
