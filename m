From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND][PATCH 2.6.28] myri10ge: use DCA if DCA is compiled as
 a module
Date: Sat, 13 Sep 2008 18:40:09 -0400
Message-ID: <48CC4149.3060205@garzik.org>
References: <48CC259F.4000903@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50958 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751623AbYIMWkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 18:40:12 -0400
In-Reply-To: <48CC259F.4000903@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Use DCA in myri10ge when CONFIG_DCA_MODULE is set as well.
> 
> And thus force INTEL_IOATDMA to =y so that DCA=y if we are =y.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/Kconfig             |    1 +
>  drivers/net/myri10ge/myri10ge.c |   26 +++++++++++++-------------
>  2 files changed, 14 insertions(+), 13 deletions(-)

applied


