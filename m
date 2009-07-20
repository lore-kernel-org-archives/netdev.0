From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 14:07:30 +0200
Message-ID: <1248091650.4549.107.camel@violet>
References: <200907201247.23020.remi.denis-courmont@nokia.com>
	 <1248085261.4549.103.camel@violet>
	 <200907201332.05329.remi.denis-courmont@nokia.com>
	 <20090720.034328.193709571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:41908 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157AbZGTMIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 08:08:02 -0400
In-Reply-To: <20090720.034328.193709571.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > On Monday 20 July 2009 13:21:01 ext Marcel Holtmann wrote:
> >> > It's just like most network protocols exposing their sockets list in
> >> > /proc/net. Debugging/monitoring indeed.
> >>
> >> I think that for new protocols, we should not do this anymore and just
> >> use debugfs. Since that is exactly its job.
> > 
> > Requiring debugfs for something like 'netstat' sounds restrictive to me...
> 
> Me too.

hold on, what has netstat to do with Phonet support? Does netstat now
support Phonet or what are we trying to achieve here?

And if we are talking about debugging information, then they should go
into debugfs and not /proc. At least for new protocols.

Regards

Marcel


