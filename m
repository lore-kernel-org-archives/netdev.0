From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] 8390: Don't oops on starting dev queue
Date: Thu, 28 Oct 2010 16:22:39 +0400
Message-ID: <4CC96B0F.1070702@parallels.com>
References: <4CC93BCE.4020303@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29164 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407Ab0J1MW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 08:22:56 -0400
In-Reply-To: <4CC93BCE.4020303@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2010 01:01 PM, Pavel Emelyanov wrote:
> The __NS8390_init tries to start the device queue before the
> device is registered. This results in an oops (snipped):

I've found the commit, that broke the driver.
It was Tom's e6484930 (net: allocate tx queues in register_netdevice)
