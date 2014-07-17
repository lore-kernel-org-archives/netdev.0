From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] dp83640: Fix receive timestamp race condition
Date: Thu, 17 Jul 2014 21:24:24 +0200
Message-ID: <20140717192424.GA24456@localhost.localdomain>
References: <1405603079-23572-1-git-send-email-stefan.sorensen@spectralink.com>
 <20140717181222.GB23623@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41019 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaGQTYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 15:24:45 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so2485516wgh.3
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 12:24:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140717181222.GB23623@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 08:12:22PM +0200, Richard Cochran wrote:
> 
> And what happens when the timestamp arrives *before* the PTP packet?

It could also happen that the MAC driver re-orders the packets. Think
about multiple hardware queues putting multicast UDP to one side, etc.
Sure, maybe not a typical combination with the phyter, but still the
driver should handle this.

Thanks,
Richard
