From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] netdevice: Neaten includes and forward
 declarations
Date: Tue, 18 Nov 2014 13:09:38 -0800
Message-ID: <1416344978.6651.8.camel@perches.com>
References: <1416091109.5912.32.camel@perches.com>
	 <20141116.154923.1364136096942964102.davem@davemloft.net>
	 <1416176491.24600.3.camel@perches.com>
	 <20141118.154831.22639502436697791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0195.hostedemail.com ([216.40.44.195]:55395 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932586AbaKRVJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 16:09:41 -0500
In-Reply-To: <20141118.154831.22639502436697791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-18 at 15:48 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sun, 16 Nov 2014 14:21:31 -0800
> 
> > Use the appropriate #include path for neighbour.h and
> > add device.h which was indirectly #included by dmaengine.h
> > 
> > Remove unnecessary forward declaration of struct device;
> > 
> > Add comments for other forward struct declarations.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> This no longer applies to net-next, please respin.
> 
> Thanks.

I did this against -next.

There, commit 98a18b6ffc79b
("netdevice: add ieee802154_ptr to net_device")

adds a forward reference to struct wpan_dev

So, I can do this against net-next, but it'll
just collide with that commit.

It's not at all urgent so perhaps it'd be better
to wait until the next cycle.
