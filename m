From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: support IFA_F_MANAGETEMPADDR for address deletion too
Date: Tue, 22 Apr 2014 17:05:43 +0200
Message-ID: <20140422150543.GB1960@order.stressinduktion.org>
References: <53542020.8070904@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heiner Kallweit <heiner.kallweit@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59900 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932769AbaDVPFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 11:05:44 -0400
Content-Disposition: inline
In-Reply-To: <53542020.8070904@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 20, 2014 at 09:29:36PM +0200, Heiner Kallweit wrote:
> Userspace applications can use IFA_F_MANAGETEMPADDR with RTM_NEWADDR
> already to indicate that the kernel should take care of temporary
> address management.
> 
> This patch adds related functionality to RTM_DELADDR. By setting
> IFA_F_MANAGETEMPADDR a userspace application can indicate that the kernel
> should delete all related temporary addresses as well.
> 
> A corresponding patch for the "ip addr del" command has been applied to
> iproute2 already.
> 
> Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
