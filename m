From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v3] [8/10] pasemi_mac: Add msglevel support and "pasemi_mac_debug"
 module param
Date: Tue, 08 May 2007 01:03:12 -0400
Message-ID: <46400490.4080606@garzik.org>
References: <20070428203624.GA4331@lixom.net> <20070428203803.GI4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54206 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967819AbXEHFDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:03:14 -0400
In-Reply-To: <20070428203803.GI4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> +	/* Enable most messages by default */
> +	if (pasemi_mac_debug > 0)
> +		mac->msg_enable = DEFAULT_MSG_ENABLE;
> +	else
> +		mac->msg_enable = pasemi_mac_debug;
> +


use netif_msg_init()

otherwise OK

