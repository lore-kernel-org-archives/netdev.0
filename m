From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Thu, 6 Nov 2014 15:32:54 +0100
Message-ID: <20141106143254.GB1854@nanopsycho.orion>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
 <20141106141130.GA18208@casper.infradead.org>
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46758 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbaKFOdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 09:33:01 -0500
Received: by mail-wi0-f174.google.com with SMTP id d1so1670488wiv.1
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 06:33:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141106141130.GA18208@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 06, 2014 at 03:11:30PM CET, tgraf@suug.ch wrote:
>On 11/06/14 at 10:20am, Jiri Pirko wrote:
>> As to the discussion if there is need to have specific class of device
>> representing the switch itself, so far we found no need to introduce that.
>> But we are generally ok with the idea and when the time comes and it will
>> be needed, it can be easily introduced without any disturbance.
>
>I remember that concerns were raised in Duesseldorf and before that
>reusing net_device would imply the expectation of packet rx/tx on that
>net_device which might not necessarily be possible.

For switch object there was an agreement to not use net_device but do
something similar to what wireless does. But this is not subject of
this patchset.

For switch ports, I believe that there is a general agreement to
represent them as net_devices. This patchset does that. Also, you are able to
use this devs as ordinary NICs, set ip on each of tnem and rx/tx.
But of course, the primary usecase is to put them in bridge.

>
>Whereas the model of representing the hardware switch with a
>combination of Linux bridge + switchdev class would ease fullfiling
>existing expecations towards net_device.
>
>That said, I don't see why this shouldn't happen as an evolutionary
>step on top of these patches.

I agree.
