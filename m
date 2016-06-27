From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: avoid vlan ptype specific match to be leaked
 on real device
Date: Mon, 27 Jun 2016 09:43:25 -0400 (EDT)
Message-ID: <20160627.094325.1714258358214027207.davem@davemloft.net>
References: <20160622124050.GD2068@nanopsycho.orion>
	<20160626.160608.2073563033978522175.davem@davemloft.net>
	<1467019712.4606.7.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jiri@mellanox.com,
	aduyck@mirantis.com, edumazet@google.com, daniel@iogearbox.net
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbcF0OAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:00:43 -0400
In-Reply-To: <1467019712.4606.7.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 27 Jun 2016 11:28:32 +0200

> On Sun, 2016-06-26 at 16:06 -0400, David Miller wrote:
>> From: Jiri Pirko <jiri@resnulli.us>
>> Date: Wed, 22 Jun 2016 14:40:50 +0200
>> 
>> > The patch only unified the behaviour so everyone know what to expect
>> > regardless of the device type.
>> 
>> +1
>> 
>> And reverting this behavior back is going to hurt more people than it
>> will help, so I am not going to apply this, sorry.
> 
> Would a /proc/net/vlan sysctl to control the switch from the new to the
> old behavior (with default to the new) make this acceptable ?

No, sorry.  Please fix your applications while you have your attention
on the issue and have the opportunity and impetus to do so.
