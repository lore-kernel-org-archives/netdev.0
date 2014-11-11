From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 05/10] rocker: introduce rocker switch driver
Date: Tue, 11 Nov 2014 16:10:36 +0000
Message-ID: <20141111161036.GI19157@casper.infradead.org>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-6-git-send-email-jiri@resnulli.us>
 <5461366A.9050900@gmail.com>
 <20141111142946.GG19157@casper.infradead.org>
 <20141111151928.GF1825@nanopsycho.lan>
 <20141111153232.GH19157@casper.infradead.org>
 <20141111154017.GH1825@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
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
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cum
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38009 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaKKQKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 11:10:41 -0500
Content-Disposition: inline
In-Reply-To: <20141111154017.GH1825@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/14 at 04:40pm, Jiri Pirko wrote:
> Tue, Nov 11, 2014 at 04:32:32PM CET, tgraf@suug.ch wrote:
> >If the ID is only unique within a driver, then the user space cannot
> >rely on using the ID to group switch ports. Multiple drivers might
> >come up with the same ID.
> 
> Well, as I said, it is the same as for physical port id. But if needed,
> there can be added some simple mechanism for the id registration
> ensuring their uniqueness.
> 
> >
> >Even now, multiple rocker instances would have the same ID.
> 
> It depends on what hw returns to driver.

I think that falls within the responsibility of the API. I'll propose
a patch to address it after this gets in.
