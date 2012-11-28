From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix memory leak in sctp_datamsg_from_user() when
 copy from user space fails
Date: Wed, 28 Nov 2012 11:11:48 -0500 (EST)
Message-ID: <20121128.111148.259100136370359105.davem@davemloft.net>
References: <20121126.173429.323283427379416132.davem@davemloft.net>
	<1354024906-1925-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, vyasevich@gmail.com, sri@us.ibm.com,
	davej@redhat.com
To: tt.rantala@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab2K1QLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:11:53 -0500
In-Reply-To: <1354024906-1925-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tommi Rantala <tt.rantala@gmail.com>
Date: Tue, 27 Nov 2012 16:01:46 +0200

> Trinity (the syscall fuzzer) discovered a memory leak in SCTP,
> reproducible e.g. with the sendto() syscall by passing invalid
> user space pointer in the second argument:
...
> As far as I can tell, the leak has been around since ~2003.
> 
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>

Applied.
