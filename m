From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: avoid vlan ptype specific match to be leaked
 on real device
Date: Sun, 26 Jun 2016 16:06:08 -0400 (EDT)
Message-ID: <20160626.160608.2073563033978522175.davem@davemloft.net>
References: <20160622105544.GC2068@nanopsycho.orion>
	<1466598089.4707.31.camel@redhat.com>
	<20160622124050.GD2068@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, jiri@mellanox.com,
	aduyck@mirantis.com, edumazet@google.com, daniel@iogearbox.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbcFZUG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 16:06:59 -0400
In-Reply-To: <20160622124050.GD2068@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 22 Jun 2016 14:40:50 +0200

> The patch only unified the behaviour so everyone know what to expect
> regardless of the device type.

+1

And reverting this behavior back is going to hurt more people than it
will help, so I am not going to apply this, sorry.
