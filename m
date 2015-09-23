From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/7] bridge: don't age out externally added
 FDB entries
Date: Wed, 23 Sep 2015 14:36:46 -0700 (PDT)
Message-ID: <20150923.143646.1111978912183035009.davem@davemloft.net>
References: <1443022760-21301-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbbIWVgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:36:48 -0400
In-Reply-To: <1443022760-21301-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 23 Sep 2015 08:39:13 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> v3: Per davem review: add del_timer_sync on rocker port remove.
> 
> v2: Per Jiri review comment: add BR_DEFAULT_AGEING_TIME to defines
> 
> Siva originally proposed skipping externally added FDB entries in the bridge's
> FDB garbage collection func, and moving the ageing of externally added entries
> to the port driver/device.  This broke rocker, since rocker didn't have a
> hardware (or software) mechanism for ageing out its learned FDB entries.
> 
> This patchset reintroduces Siva's bridge driver patch to skip externally added
> entries and adds support in rocker so rocker can age out its own entries.
> Rocker does this using a software timer similar to the bridge's FDB garbage
> collection timer.  Other switchdev devices/drivers can use this software timer
> method or program the device to nofity aged-out entries to the driver.
> 
> Updated switchdev.txt documentation to reflect current state-of-the-art.  This
> removes one more XXX todo comment in switchdev.txt.

Series applied, thanks Scott.
