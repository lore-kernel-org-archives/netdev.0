From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] sky2: avoid reserved regions on ethtool reg dump
Date: Wed, 13 Jun 2007 16:44:22 -0400
Message-ID: <46705726.6030304@pobox.com>
References: <20070605002320.868185090@linux-foundation.org> <20070605002738.626584893@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39657 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbXFMUoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:44:25 -0400
In-Reply-To: <20070605002738.626584893@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Yukon EX reading some of the undocumented places in the
> memory space will cause a hang. Since they don't provide useful
> information, just skip the reserved areas.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/sky2.c |   14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)

applied 1-7 to #upstream (2.6.23)


