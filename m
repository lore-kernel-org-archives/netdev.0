From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax/i2400m: driver loads firmware v1.4 instead of
 v1.3
Date: Fri, 20 Feb 2009 00:36:22 -0800 (PST)
Message-ID: <20090220.003622.150952591.davem@davemloft.net>
References: <1235083229-25620-1-git-send-email-inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33383
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754349AbZBTIgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:36:40 -0500
In-Reply-To: <1235083229-25620-1-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Thu, 19 Feb 2009 14:40:29 -0800

> This is a one liner change to have the driver use by default the v1.4
> of the i2400m firmware instead of v1.3. The v1.4 version of the
> firmware has been submitted to David Woodhouse for inclusion in the
> linux-firmware tree and it is already available at
> http://linuxwimax.org/Download.
> 
> The reason for this change is that the 1.3 release of the user space
> software and firmware has a few issues that will make it difficult to
> use with currently deployed commercial networks such as Xohm and
> Clearwire.
> 
> As well, the new 1.4 release of the user space software (which matches
> the 1.4 firmware) has intermitent issues with the 1.3 firmware.
> 
> The 1.4 release in http://linuxwimax.org/Download has been widely
> deployed and tested with the codebase in 2.6.29-rc, the 1.4 firmware
> and the 1.4 user space components.
> 
> We understand it is quite late in the rc process for such a change,
> but would like to ask for the change to be taken into consideration.
> 
> Alternatively, a user could always force feed a 1.4 firmware into a
> driver that doesn't have this modification by:
> 
> $ cd /lib/firmware
> $ mv i2400m-fw-usb-1.3.sbcf i2400m-fw-usb-1.3.real.sbcf
> $ ln -sf i2400m-fw-usb-1.4.sbc i2400m-fw-usb-1.3.sbcf
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

Applied.
