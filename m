From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: fix comparisons of unsigned < 0
Date: Wed, 13 Jun 2007 15:45:54 -0400
Message-ID: <46704972.5020900@garzik.org>
References: <20070530075902.GA29118@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: notting@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38905 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623AbXFMTp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 15:45:57 -0400
In-Reply-To: <20070530075902.GA29118@nostromo.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Nottingham wrote:
> Recent gcc versions emit warnings when unsigned variables are compared < 0 or >= 0.
> 
> Signed-off-by: Bill Nottingham <notting@redhat.com>
> 
> ---
>  mlx4/qp.c               |    3 +--
>  netxen/netxen_nic_niu.c |    6 +++---
>  tulip/de2104x.c         |    1 -
>  3 files changed, 4 insertions(+), 6 deletions(-)

applied to #upstream (2.6.23)

BTW please fix your Mail-Followup-To header


