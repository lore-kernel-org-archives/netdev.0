From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Tue, 25 Nov 2014 21:54:02 +0000
Message-ID: <20141125215402.GA3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-5-git-send-email-jiri@resnulli.us>
 <5474A567.4040401@mojatatu.com>
 <20141125164954.GJ1971@nanopsycho.orion>
 <5474B795.3080204@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56553 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbaKYVyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 16:54:09 -0500
Content-Disposition: inline
In-Reply-To: <5474B795.3080204@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 12:08pm, Jamal Hadi Salim wrote:
> On 11/25/14 11:49, Jiri Pirko wrote:
> 
> >
> >What does it do? "L3 switching"?
> >
> 
> Absolutely not - that is too easy;-> Why not just a mellanox
> chip for that? (Testing if Aviad is awake). But flows and associated
> constructs apply.

It would definitely help if you could expose some more details on the
"some network processor" you have. We're all very eager ;-)

> I think this interface is usable for example to offload to user space
> ala DPDK and friends just as it would be for ASICs or standard NIC
> offload (which we already have with fdb offload).
> I dont know what a good name is - but switch looks incorrect.

I'm with Jiri but I agree it's not a perfect fit. I doubt there is but
if you can come up with something that fits better I'm open to it.

I considered "dataplane" or "dp" for a bit but it's quite generic as
well.
