From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/9] igb: Add support functions to access thermal
 data.
Date: Sun, 10 Jun 2012 01:48:53 +0100
Message-ID: <1339289333.21665.156.camel@deadeye.wl.decadent.org.uk>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1339230063-12545-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Carolyn Wyborny <carolyn.wyborny@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28384 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753306Ab2FJAs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 20:48:59 -0400
In-Reply-To: <1339230063-12545-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-09 at 01:20 -0700, Jeff Kirsher wrote:
> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> Some i350 devices contain thermal data that we can get to via an i2c
> interface.  These functions provide support to get at that data.  A
> following patch will export this data.
[...]

We already have an I2C subsystem - so don't replicate i2c-algo-bit etc.

It's possible we also have an hwmon driver for whatever temperature
sensor is on these boards, which you can then probe by calling
i2c_new_device().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
