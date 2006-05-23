From: Olivier Blin <oblin@mandriva.com>
Subject: Re: [PATCH 1/5] new pcmcia IDs for hostap - ASUS WL-110
Date: Tue, 23 May 2006 17:40:02 +0200
Message-ID: <m3hd3gpx65.fsf@dynamo.mandriva.com>
References: <20060512165706.GA4079@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ezoffice.mandriva.com ([84.14.106.134]:18436 "EHLO
	office.mandriva.com") by vger.kernel.org with ESMTP
	id S1750729AbWEWPkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 11:40:05 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060512165706.GA4079@bougret.hpl.hp.com> (Jean Tourrilhes's message of "Fri, 12 May 2006 09:57:06 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean Tourrilhes <jt@hpl.hp.com> writes:

> 	The overall architecture of hotplug/udev module loading is
> broken as it does not allow user override. I have explained in details
> the problem to the concerned people, but it seems that they don't
> really care. The standard answer is "blacklist the orinoco
> module". Let's not even mention libusual.

You can also have a local alias overriding in a /etc/modprobe.d/ file,
for example:
alias pcmcia:m02AAc0002f*fn*pfn*pa*pb*pc*pd* hostap_cs

modprobe will use this alias only, since it doesn't look in
module.alias if the alias is resolved before.

This allows to override the driver for a specific card, without
blacklisting a driver still usable with a whole number of cards.

Regards

-- 
Olivier Blin - Mandriva
