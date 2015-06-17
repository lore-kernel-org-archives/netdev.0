From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal with
 0x in the printf format
Date: Wed, 17 Jun 2015 10:25:43 +0100
Message-ID: <1434533143.13744.273.camel@citrix.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	 <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:45317 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbbFQJZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 05:25:46 -0400
In-Reply-To: <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-16 at 20:10 +0100, Julien Grall wrote:
> Append 0x to all %x in order to avoid while reading when there is other
> decimal value in the log.
> 
> Also replace some of the hexadecimal print to decimal to uniformize the
> format with netfront.
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: netdev@vger.kernel.org

You meant s/Append/Prepend/, nonetheless:

Acked-by: Ian Campbell <ian.campbell@citrix.com>
