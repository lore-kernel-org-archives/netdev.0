From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH torvalds-2.6] cdc_ether: fix autosuspend for mbm devices
Date: Mon, 26 Apr 2010 12:30:21 +0200
Message-ID: <201004261230.21713.oneukum@suse.de>
References: <201004261214.13836.torgny.johansson@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Torgny Johansson <torgny.johansson@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:57504 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766Ab0DZKaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 06:30:23 -0400
In-Reply-To: <201004261214.13836.torgny.johansson@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 26. April 2010 12:14:13 schrieb Torgny Johansson:
> Hi!
> 
> In 2.6.33 it seems autosuspend is broken for mbm devices.

It is hardly broken. It simply wasn't implemented.

> Autosuspend works until you bring the wwan interface up, then the device does not enter autosuspend anymore.
> 
> The following patch fixes the problem by setting the .manage_power field in the mbm_info struct 
> to the same as in the cdc_info struct (cdc_manager_power).
> 
> I am unsure exactly what that does and why autosuspend doesn't work without it. 
> Can you guys comment on that? Is this fix the correct approach?

The patch is correct. If you use another struct driver_info it is a different
driver as far as usbnet is concerned. A driver needs to give some
minimal support for autosuspend. mbm didn't do so.
 
> Also, if you like this patch, is it possible to get it included in a minor release of 2.6.33 (e.g. 2.6.33.3) as a bugfix?

Up to David.

	Regards
		Oliver
