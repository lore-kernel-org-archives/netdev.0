From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] skge: deadlock on tx timeout
Date: Fri, 23 Mar 2007 01:48:48 -0400
Message-ID: <46036A40.4010808@pobox.com>
References: <20070316210125.324052637@linux-foundation.org> <20070316210155.813001089@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60427 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113AbXCWFsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:48:51 -0400
In-Reply-To: <20070316210155.813001089@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The skge driver will deadlock if gets a transmit timeout
> because the netif_tx_lock() is already held.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-3 to #upstream-fixes


