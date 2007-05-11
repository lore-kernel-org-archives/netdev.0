From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21 1/3]S2IO: getringparam ethtool option
Date: Fri, 11 May 2007 16:55:21 -0400
Message-ID: <4644D839.4070706@garzik.org>
References: <Pine.GSO.4.10.10705100351060.23138-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alicia.Pena@neterion.com,
	Leonid.Grossman@neterion.com, ramkrishna.vep@neterion.com,
	santosh.rastapur@neterion.com, Sivakumar.Subramani@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42302 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760034AbXEKUzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:55:25 -0400
In-Reply-To: <Pine.GSO.4.10.10705100351060.23138-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sreenivasa Honnur wrote:
> Adding get_ringparam ethtool option.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

applied 1-3

Please send follow-up patch that removes braces around single C statements:

> +	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
> +		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
> +	}


