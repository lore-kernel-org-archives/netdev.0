From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Thu, 6 Nov 2014 14:11:30 +0000
Message-ID: <20141106141130.GA18208@casper.infradead.org>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54549 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbaKFOLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 09:11:42 -0500
Content-Disposition: inline
In-Reply-To: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/14 at 10:20am, Jiri Pirko wrote:
> As to the discussion if there is need to have specific class of device
> representing the switch itself, so far we found no need to introduce that.
> But we are generally ok with the idea and when the time comes and it will
> be needed, it can be easily introduced without any disturbance.

I remember that concerns were raised in Duesseldorf and before that
reusing net_device would imply the expectation of packet rx/tx on that
net_device which might not necessarily be possible.

Whereas the model of representing the hardware switch with a
combination of Linux bridge + switchdev class would ease fullfiling
existing expecations towards net_device.

That said, I don't see why this shouldn't happen as an evolutionary
step on top of these patches.
