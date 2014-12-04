From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 4 Dec 2014 15:37:41 +0000
Message-ID: <20141204153741.GB32140@casper.infradead.org>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
 <1417683438-10935-2-git-send-email-jiri@resnulli.us>
 <20141204142015.GR27416@gospo.rtplab.test>
 <20141204143306.GB1861@nanopsycho.orion>
 <20141204145743.GS27416@gospo.rtplab.test>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org,
	hema
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51949 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547AbaLDPhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 10:37:48 -0500
Content-Disposition: inline
In-Reply-To: <20141204145743.GS27416@gospo.rtplab.test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/14 at 09:57am, Andy Gospodarek wrote:
> I know that attribute is there, but I find it more valuable for
> solutions like nPAR than for PF/VF use-case.  Parent/child relationship
> makes more sense to me since for forwarding will be controlled by the
> embedded switch on those devices.  (Notice I specifically chose not to
> use 'master' since that is already overloaded by bridge, bonding,
> teaming, etc.)

So that would make it link, master, and parent. Not sure we can make
it any more confusing ;-)

TBH, I'm really struggling on how to best name this. Trying to reach
for 100% correctness leads to generic, amgbigous names. 
