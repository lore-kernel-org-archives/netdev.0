From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] myri10ge: large receive offload
Date: Tue, 27 Feb 2007 04:15:08 -0500
Message-ID: <45E3F69C.8010003@garzik.org>
References: <45DC7B8C.9070501@myri.com> <45DC7BF8.1030507@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47347 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161070AbXB0JPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:15:10 -0500
In-Reply-To: <45DC7BF8.1030507@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Add Large Receive Offload implemented in software.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |  422 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 422 insertions(+)

Another patch to do this for another driver just came up as well.  I 
would rather see some helpers in the net core make this easier on the 
NIC author, rather than reimplementing the same concept over and over again.

