From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: support IFA_F_MANAGETEMPADDR for
 address deletion too
Date: Tue, 22 Apr 2014 21:28:12 -0400 (EDT)
Message-ID: <20140422.212812.554586662327026593.davem@davemloft.net>
References: <53542020.8070904@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: heiner.kallweit@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841AbaDWB2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 21:28:14 -0400
In-Reply-To: <53542020.8070904@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiner Kallweit <heiner.kallweit@web.de>
Date: Sun, 20 Apr 2014 21:29:36 +0200

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

Applied.
