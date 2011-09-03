From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usbnet: ignore get interface retval of -EINPROGRESS
Date: Sat, 3 Sep 2011 18:37:48 +0200
Message-ID: <201109031837.48444.oliver@neukum.org>
References: <CAPopfEUUaEChuh1mdZnHHT_9uRfsQmwMu7=gjnYr=AmFWik2HA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jim Wylder <jwylder1@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:50704 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab1ICQeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 12:34:31 -0400
In-Reply-To: <CAPopfEUUaEChuh1mdZnHHT_9uRfsQmwMu7=gjnYr=AmFWik2HA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, 3. September 2011, 16:21:00 schrieb Jim Wylder:
> When calling pm_runtime_get, usb_autopm_get_interface_async
> treats a return value of -EINPROGRESS as a success and
> increments the usage count.  Since the interface is resuming,
> it is safe for usbnet_start_xmit to submit the urb.

usbnet_start_xmit() is exported, so simply stating that it is
called when the interface is resumingisn't enough. It seems to
me that the later check for DEV_ASLEEP will save as, but have
you checked for that?

	Regards
		Oliver
