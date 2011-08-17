From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [net-next RFC PATCH 7/7] virtio-net changes
Date: Wed, 17 Aug 2011 13:24:59 +0000 (UTC)
Message-ID: <j2gff7$cn1$1@dough.gmane.org>
References: <20110812015221.31613.95001.stgit@intel-e5620-16-2.englab.nay.redhat.com>
	<20110812015551.31613.13885.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: qemu-devel@nongnu.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:33667 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753389Ab1HQNZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2011 09:25:15 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Qtg7N-00057b-Or
	for netdev@vger.kernel.org; Wed, 17 Aug 2011 15:25:13 +0200
Received: from 116.53.101.235 ([116.53.101.235])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2011 15:25:13 +0200
Received: from xiyou.wangcong by 116.53.101.235 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2011 15:25:13 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Aug 2011 09:55:51 +0800, Jason Wang wrote:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Implement mq virtio-net driver.
> 
> Though struct virtio_net_config changes, it works with the old qemu
> since the last element is not accessed unless qemu sets
> VIRTIO_NET_F_MULTIQUEUE.
> 
...
> +
> +#if 1
<...>
> +#else
<...>
> +#endif

Any reason to keep this #else code of #if 1? which is dead.

