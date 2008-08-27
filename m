From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/1] NET: e100, fix iomap read
Date: Wed, 27 Aug 2008 05:56:10 -0400
Message-ID: <48B524BA.9010401@pobox.com>
References: <1218731243-32732-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42002 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753475AbYH0J4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:56:17 -0400
In-Reply-To: <1218731243-32732-1-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby wrote:
> There were 2 omitted readb's used on an iomap space. eliminate them
> by using ioread8 instead.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> ---
>  drivers/net/e100.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied


