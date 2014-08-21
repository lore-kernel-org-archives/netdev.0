From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic switch devices
 support
Date: Thu, 21 Aug 2014 19:03:01 +0200
Message-ID: <20140821170301.GA10633@nanopsycho.lan>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-4-git-send-email-jiri@resnulli.us>
 <1408639283.13073.3.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:45664 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbaHURDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 13:03:06 -0400
Received: by mail-we0-f173.google.com with SMTP id q58so9654466wes.32
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 10:03:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1408639283.13073.3.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 21, 2014 at 06:41:23PM CEST, ben@decadent.org.uk wrote:
>On Thu, 2014-08-21 at 18:18 +0200, Jiri Pirko wrote:
>> The goal of this is to provide a possibility to suport various switch
>> chips. Drivers should implement relevant ndos to do so. Now there is a
>> couple of ndos defines:
>> - for getting physical switch id is in place.
>> - for work with flows.
>> 
>> Note that user can use random port netdevice to access the switch.
>[...]
>
>Why isn't the switch treated as a real device (not necessarily a net
>device) that's included in the device model and that the port devices
>refer to?

That is certainly possible. But so far, there is no need for it. But I
guess that it's probably a good idea at least to put it into sysfs
structure.

Noted, thanks Ben.

>
>Ben.
>
>-- 
>Ben Hutchings
>If at first you don't succeed, you're doing about average.
