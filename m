From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] myri10ge: limit the number of recoveries
Date: Tue, 12 Jun 2007 22:28:48 -0400
Message-ID: <466F5660.6090000@garzik.org>
References: <466D9380.7090605@myri.com> <466D93D7.5060604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60225 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbXFMC2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 22:28:51 -0400
In-Reply-To: <466D93D7.5060604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Limit the number of recoveries from a NIC hw watchdog reset to 1 by default.
> It enables detection of defective NICs immediately since these memory parity
> errors are expected to happen very rarely (less than once per century*NIC).
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)

applied 1-3 to #upstream-fixes


