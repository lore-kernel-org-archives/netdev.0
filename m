From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: proc: fix build failed when procfs is not
 configured
Date: Tue, 19 Feb 2013 13:19:26 -0500 (EST)
Message-ID: <20130219.131926.781333335958742182.davem@davemloft.net>
References: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932858Ab3BSST1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 13:19:27 -0500
In-Reply-To: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Tue, 19 Feb 2013 18:43:10 +0800

> commit d4beaa66add8aebf83ab16d2fde4e4de8dac36df
> "net: proc: change proc_net_fops_create to proc_create"
> uses proc_create to replace proc_net_fops_create, when
> CONFIG_PROC isn't configured, some build error will
> occurs.
> 
> net/packet/af_packet.c: In function 'packet_net_init':
> net/packet/af_packet.c:3831:48: error: 'packet_seq_fops' undeclared (first use in this function)
> net/packet/af_packet.c:3831:48: note: each undeclared identifier is reported only once for each function it appears in
> 
> There may be other build fails like above,this patch
> change proc_create from function to macros when CONFIG_PROC
> is not configured,just like what proc_net_fops_create did
> before this commit.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied.
