From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix -ENOMEM result with invalid user space
 pointer in sendto() syscall
Date: Sun, 25 Nov 2012 16:03:11 -0500 (EST)
Message-ID: <20121125.160311.1193801954973499889.davem@davemloft.net>
References: <1353590596-12216-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, vyasevich@gmail.com, sri@us.ibm.com,
	davej@redhat.com
To: tt.rantala@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390Ab2KYVDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 16:03:15 -0500
In-Reply-To: <1353590596-12216-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tommi Rantala <tt.rantala@gmail.com>
Date: Thu, 22 Nov 2012 15:23:16 +0200

> Consider the following program, that sets the second argument to the
> sendto() syscall incorrectly:
 ...
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>

This also looks good, Vlad please review this.

Thanks.
