From: Oliver Neukum <oliver@neukum.org>
Subject: Re: future developments of usbnet
Date: Sat, 14 May 2011 12:01:40 +0200
Message-ID: <201105141201.40265.oliver@neukum.org>
References: <Pine.LNX.4.44L0.1105121025360.1917-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	tom.leiming@gmail.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:41669 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab1ENJ7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 05:59:51 -0400
In-Reply-To: <Pine.LNX.4.44L0.1105121025360.1917-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 12. Mai 2011, 16:37:28 schrieb Alan Stern:
> Therefore usbnet's poll routine should take the "weight" argument as an
> indication of how many outstanding rx URBs are allowed.  Each time the
> poll routine is called, it should check to see if any rx URBs have
> completed since the previous poll.  If not then there is no network
> traffic, so usbnet can take itself out of the poll loop.  Otherwise,
> the number of outstanding URBs should be adjusted (by unlinking some or
> submitting more -- subject to some fixed maximum limit) to match the
> new "weight".
> 
> Does that make sense?

What does happen if we reach the weight 0 ?

	Regards
		Oliver
