From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] seeq: use PTR_RET at init_module of driver
Date: Sun, 29 Jul 2012 18:41:50 +0100
Message-ID: <12831.1343583710@warthog.procyon.org.uk>
References: <1343568527-12729-1-git-send-email-develkernel412222@gmail.com>
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Pradeep A Dalvi <netdev@pradeepdalvi.com>,
	netdev@vger.kernel.org
To: Devendra Naga <develkernel412222@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab2G2RmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2012 13:42:00 -0400
In-Reply-To: <1343568527-12729-1-git-send-email-develkernel412222@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Devendra Naga <develkernel412222@gmail.com> wrote:

> the driver sees wether the dev_seeq pointer is having a error that can be
> read by using the PTR_ERR, and returns it at error case, other wise 0 at
> success case.
> 
> the PTR_RET does the same thing, and use PTR_RET instead of redoing the
> code of PTR_RET
> 
> Signed-off-by: Devendra Naga <develkernel412222@gmail.com>

Acked-by: David Howells <dhowells@redhat.com>
