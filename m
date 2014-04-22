From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix ns_capable check in sock_diag_put_filterinfo
Date: Tue, 22 Apr 2014 12:54:36 -0400 (EDT)
Message-ID: <20140422.125436.390962866710056909.davem@davemloft.net>
References: <1360f6acc2064d49a41f2d993d05cdcf8a40fc06.1397709384.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932504AbaDVQym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 12:54:42 -0400
In-Reply-To: <1360f6acc2064d49a41f2d993d05cdcf8a40fc06.1397709384.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 16 Apr 2014 21:41:34 -0700

> The caller needs capabilities on the namespace being queried, not on
> their own namespace.  This is a security bug, although it likely has
> only a minor impact.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Applied, thanks.
