From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] sctp: fix /proc/net/sctp/ memory leak
Date: Thu, 15 Nov 2012 13:56:23 -0500 (EST)
Message-ID: <20121115.135623.45874794041542310.davem@davemloft.net>
References: <1352987345-11263-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	sri@us.ibm.com, linux-sctp@vger.kernel.org, davej@redhat.com,
	ebiederm@xmission.com
To: tt.rantala@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423636Ab2KOS43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 13:56:29 -0500
In-Reply-To: <1352987345-11263-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tommi Rantala <tt.rantala@gmail.com>
Date: Thu, 15 Nov 2012 15:49:05 +0200

> Commit 13d782f ("sctp: Make the proc files per network namespace.")
> changed the /proc/net/sctp/ struct file_operations opener functions to
> use single_open_net() and seq_open_net().
> 
> Avoid leaking memory by using single_release_net() and seq_release_net()
> as the release functions.
> 
> Discovered with Trinity (the syscall fuzzer).
> 
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
