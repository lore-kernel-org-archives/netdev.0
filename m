From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] net: avoid vlan ptype specific match to be leaked
 on real device
Date: Mon, 27 Jun 2016 11:28:32 +0200
Message-ID: <1467019712.4606.7.camel@redhat.com>
References: <20160622105544.GC2068@nanopsycho.orion>
	 <1466598089.4707.31.camel@redhat.com>
	 <20160622124050.GD2068@nanopsycho.orion>
	 <20160626.160608.2073563033978522175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jiri@mellanox.com,
	aduyck@mirantis.com, edumazet@google.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215AbcF0J2g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:28:36 -0400
In-Reply-To: <20160626.160608.2073563033978522175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-06-26 at 16:06 -0400, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Wed, 22 Jun 2016 14:40:50 +0200
> 
> > The patch only unified the behaviour so everyone know what to expect
> > regardless of the device type.
> 
> +1
> 
> And reverting this behavior back is going to hurt more people than it
> will help, so I am not going to apply this, sorry.

Would a /proc/net/vlan sysctl to control the switch from the new to the
old behavior (with default to the new) make this acceptable ?

Recent users will not be affected, and users of the old behavior could
manage kernel upgrade without breaking their applications. 

Thank you,

Paolo
