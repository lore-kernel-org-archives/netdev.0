From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 4 Dec 2014 22:07:44 +0000
Message-ID: <20141204220744.GA26761@casper.infradead.org>
References: <20141204163024.GG1861@nanopsycho.orion>
 <87388v9ua6.fsf@x220.int.ebiederm.org>
 <20141204182451.GI1861@nanopsycho.orion>
 <87k327450a.fsf@x220.int.ebiederm.org>
 <20141204191926.GK1861@nanopsycho.orion>
 <87wq672p49.fsf@x220.int.ebiederm.org>
 <87h9xbxjrd.fsf@x220.int.ebiederm.org>
 <20141204202742.GM1861@nanopsycho.orion>
 <87388vw2xg.fsf@x220.int.ebiederm.org>
 <20141204211041.GN1861@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	b
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54178 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbaLDWHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 17:07:52 -0500
Content-Disposition: inline
In-Reply-To: <20141204211041.GN1861@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/14 at 10:10pm, Jiri Pirko wrote:
> Thu, Dec 04, 2014 at 09:55:07PM CET, ebiederm@xmission.com wrote:
> >My intuition says we want something like ifindex, but I am not at all
> >certain how switch id is planned to be used.  Given that it is single
> >box I don't expect you are sending it out over the wire.
> 
> No, it is not to be send out.

We discussed this before and stated we would fix this as soon as it's
merged. Let's just define a simple and quick switch id prefix generator
ala ifindex which serves as a unique prefix to all switch ids.

I have time early next week if Jiri doesn't.
