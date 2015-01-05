From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] swdev: add IPv4 routing offload
Date: Sun, 04 Jan 2015 22:17:23 -0500 (EST)
Message-ID: <20150104.221723.437611561422283552.davem@davemloft.net>
References: <1420169361-31767-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, john.fastabend@gmail.com,
	tgraf@suug.ch, jhs@mojatatu.com, andy@greyhouse.net,
	roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbbAEDR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 22:17:29 -0500
In-Reply-To: <1420169361-31767-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu,  1 Jan 2015 19:29:18 -0800

> This patch set adds L3 routing offload support for IPv4 routes.  The idea is to
> mirror routes installed in the kernel's FIB down to a hardware switch device to
> offload the data forwarding path for L3.  Only the data forwarding path is
> intercepted.  Control and management of the kernel's FIB remains with the
> kernel.

It looks like the design for this is still under discussion and that
new patches of whatever is decided upon will be forthcoming
eventually.

Can I ask you guys a huge favor?  DO NOT quote the entire patch when
discussing these changes.

The thread for patch #1 was so time consuming to scan and read in
patchwork because you guys did this.

I know it takes a little bit more work to select and delete the patch
content in the quoted area, but you really have to do this because
otherwise it is a huge burden for reviewers trying to follow the
conversation.

Thanks.
