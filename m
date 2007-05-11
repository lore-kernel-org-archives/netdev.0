From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/4] sky2: fix oops on shutdown
Date: Fri, 11 May 2007 16:58:15 -0400
Message-ID: <4644D8E7.9080000@pobox.com>
References: <20070511182143.872814956@linux-foundation.org> <20070511182251.277113203@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42370 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760811AbXEKU6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:58:17 -0400
In-Reply-To: <20070511182251.277113203@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> If the device is fails during module startup for some reason like
> unsupported chip version then the driver would crash dereferencing a
> null pointer, on shutdown or suspend/resume.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/sky2.c |   10 ++++++++++
>  1 file changed, 10 insertions(+)

applied 1-4


