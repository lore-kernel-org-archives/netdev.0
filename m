From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Thu, 21 Apr 2011 22:00:26 +0200
Message-ID: <201104212200.26551.oliver@neukum.org>
References: <Pine.LNX.4.44L0.1104210958560.1939-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Stewart <pstew@chromium.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, davem@davemloft.net, greg@kroah.com
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:37759 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab1DUT7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 15:59:13 -0400
In-Reply-To: <Pine.LNX.4.44L0.1104210958560.1939-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 21. April 2011, 16:03:34 schrieb Alan Stern:
> On Tue, 19 Apr 2011, Paul Stewart wrote:

> > This version of the patch moves the urb submit directly into
> > usbnet_resume.  Is it okay to submit a GFP_KERNEL urb from
> > usbnet_resume()?

Suppose a device of two interfaces one of them storage is autosuspended.
GFP_KERNEL in the first device to be resumed triggers a pageout to the
suspended storage device.

	Regards
		Oliver
