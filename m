From: David Miller <davem@davemloft.net>
Subject: Re: [net-next,v4] openvswitch: Add packet len info to upcall.
Date: Wed, 22 Jun 2016 16:35:16 -0400 (EDT)
Message-ID: <20160622.163516.1935037526473745406.davem@davemloft.net>
References: <1466432777-30305-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbcFVUfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 16:35:21 -0400
In-Reply-To: <1466432777-30305-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Mon, 20 Jun 2016 07:26:17 -0700

> The commit f2a4d086ed4c ("openvswitch: Add packet truncation support.")
> introduces packet truncation before sending to userspace upcall receiver.
> This patch passes up the skb->len before truncation so that the upcall
> receiver knows the original packet size. Potentially this will be used
> by sFlow, where OVS translates sFlow config header=N to a sample action,
> truncating packet to N byte in kernel datapath. Thus, only N bytes instead
> of full-packet size is copied from kernel to userspace, saving the
> kernel-to-userspace bandwidth.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

Applied.
