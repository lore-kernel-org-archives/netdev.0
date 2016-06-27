From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: avoid vlan ptype specific match to be leaked on
 real device
Date: Mon, 27 Jun 2016 11:37:36 +0200
Message-ID: <20160627093736.GD2058@nanopsycho.orion>
References: <20160622105544.GC2068@nanopsycho.orion>
 <1466598089.4707.31.camel@redhat.com>
 <20160622124050.GD2068@nanopsycho.orion>
 <20160626.160608.2073563033978522175.davem@davemloft.net>
 <1467019712.4606.7.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jiri@mellanox.com, aduyck@mirantis.com, edumazet@google.com,
	daniel@iogearbox.net
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33184 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbcF0Jhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 05:37:39 -0400
Received: by mail-wm0-f65.google.com with SMTP id r201so23016765wme.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 02:37:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1467019712.4606.7.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 27, 2016 at 11:28:32AM CEST, pabeni@redhat.com wrote:
>On Sun, 2016-06-26 at 16:06 -0400, David Miller wrote:
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
>Would a /proc/net/vlan sysctl to control the switch from the new to the
>old behavior (with default to the new) make this acceptable ?

Ugh, please don't :(

>
>Recent users will not be affected, and users of the old behavior could
>manage kernel upgrade without breaking their applications. 
>
>Thank you,
>
>Paolo
>
>
