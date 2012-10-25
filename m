From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Set default hoplimit as zero.
Date: Wed, 24 Oct 2012 23:15:11 -0400 (EDT)
Message-ID: <20121024.231511.97424602338053960.davem@davemloft.net>
References: <1351058478-29252-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527Ab2JYDPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 23:15:13 -0400
In-Reply-To: <1351058478-29252-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 24 Oct 2012 14:01:18 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Commit a02e4b7dae4551(Demark default hoplimit as zero) only changes the
> hoplimit checking condition and default value in ip6_dst_hoplimit, not
> zeros all hoplimit default value.
> 
> Keep the zeroing ip6_template_metrics[RTAX_HOPLIMIT - 1] to force it as 
> const, cause as a37e6e344910(net: force dst_default_metrics to const 
> section)
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

This bug has existed in various forms, thanks for fixing these
cases too.  (f.e. see e965c05dabdabb85af0187952ccd75e43995c4b3)

Applied and queued up for -stable.
