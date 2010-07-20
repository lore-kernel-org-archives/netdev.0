From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Tue, 20 Jul 2010 13:18:39 -0700 (PDT)
Message-ID: <20100720.131839.134093789.davem@davemloft.net>
References: <4C458CB7.3030508@redhat.com>
	<4C458F50.4070200@ixiacom.com>
	<4C4593DA.9040207@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: abadea@ixiacom.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, leedom@chelsio.com, harald@redhat.com
To: sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758636Ab0GTUSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:18:23 -0400
In-Reply-To: <4C4593DA.9040207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>
Date: Tue, 20 Jul 2010 14:17:30 +0200

> On 20.07.2010 13:58, Alex Badea wrote:
>> Hi,
>> 
>> On 07/20/2010 02:47 PM, Stefan Assmann wrote:
>>>> What about devices that 'steal' MAC addresses from slave devices?
>> 
>> Might I suggest an attribute such as "address_type", which could report
>> "permanent", "random", "stolen", or something else in the future?
> 
> In case there's demand for such a multi-purpose attribute I see no
> reason to object. More thoughts on this?

I think this is a great idea.

Now it makes sense to use a new 'u8' in struct netdevice or similar to
store this, since we'll have more than a boolean here.

