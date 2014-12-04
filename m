From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 04 Dec 2014 13:26:14 -0600
Message-ID: <87wq672p49.fsf@x220.int.ebiederm.org>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
	<1417683438-10935-2-git-send-email-jiri@resnulli.us>
	<87y4qne6if.fsf@x220.int.ebiederm.org>
	<20141204163024.GG1861@nanopsycho.orion>
	<87388v9ua6.fsf@x220.int.ebiederm.org>
	<20141204182451.GI1861@nanopsycho.orion>
	<87k327450a.fsf@x220.int.ebiederm.org>
	<20141204191926.GK1861@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
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
	bcrl@kvack.org, hemal@broadcom.c
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:48135 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbaLDT23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 14:28:29 -0500
In-Reply-To: <20141204191926.GK1861@nanopsycho.orion> (Jiri Pirko's message of
	"Thu, 4 Dec 2014 20:19:26 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

>>So this id needs to be globally unique?
>
> No. It is enough to be unique within a single system. It serves for no
> more than to find out 2 ids are same or not, no other info value.
>
> So when the drivers uses sane ids (like mac for example, or in case of
> rocker an id which is passed by qemu command line), the chances of
> collision are very very close to none (never say never).

So the switch id isn't necessarily even as good as a manufacturers
serial number that changes between different models, and anyone who uses
this id must look at the driver to get uniqueness.

Yes what is needed in the comparison to get uniqueness in a single
system badly needs to be documented because that switch id is very much
not enough on it's own.

phys_port_id on the other hand is globally unique.  So please stop
saying that this is anything like phys_port_id.

Eric
