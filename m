From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: sk98lin, jumbo frames, and memory fragmentation
Date: Mon, 01 Oct 2007 15:08:15 -0600
Message-ID: <470161BF.9010908@nortel.com>
References: <47015A24.7000701@nortel.com> <47015CE0.3080706@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@syskonnect.de, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:60132 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271AbXJAVid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 17:38:33 -0400
In-Reply-To: <47015CE0.3080706@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> The sk98lin driver is going away, please don't use it.
> 
> It's unmaintained and full of known bugs.

Okay...so it looks like the proper driver for the Marvell Yukon 88E8062 
is the sky2 driver, and this one does avoid order>0 allocations.  Am I 
on track?

Chris
