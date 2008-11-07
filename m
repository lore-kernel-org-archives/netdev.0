From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH v2] usbnet: enable more aggressive autosuspend
Date: Fri, 7 Nov 2008 12:44:16 +0100
Message-ID: <200811071244.17221.oliver@neukum.org>
References: <490080F1.1060107@t2data.se> <4913FBB9.70407@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Per Hallsmark <per.hallsmark@t2data.se>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, david-b@pacbell.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:54927 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbYKGLoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 06:44:04 -0500
In-Reply-To: <4913FBB9.70407@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 7. November 2008 09:26:33 schrieb Jeff Garzik:
> I pondered taking the easy route of fixing this by surrounding the 
> auto_pm reference with an ifdef, but it seems like usbnet could use a 
> bit more thought -- it is questionable whether usbnet_suspend/resume 
> should be built at all, if !CONFIG_PM, even though they are exported.

As this is a generic problem, shouldn't we get the compiler to do
this for us?

	Regards
		Oliver

