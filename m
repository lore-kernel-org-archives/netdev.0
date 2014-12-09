From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/3] remove bridge mode BRIDGE_MODE_SWDEV
Date: Tue, 09 Dec 2014 18:25:25 -0500 (EST)
Message-ID: <20141209.182525.6516706474261666.davem@davemloft.net>
References: <1418076261-24593-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com, netdev@vger.kernel.org,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbaLIXZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 18:25:30 -0500
In-Reply-To: <1418076261-24593-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Mon,  8 Dec 2014 14:04:18 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> BRIDGE_MODE_SWDEV was introduced to indicate switchdev offloads
> for bridging from user space (In other words to call into the hw switch
> port driver directly). But user can use existing BRIDGE_FLAGS_SELF
> to call into the hw switch port driver today. swdev mode is not required
> anymore. So, this patch removes it.
> 
> v4 - v5
>     incorporate comments
>     - Define BRIDGE_MODE_UNDEF to handle cases where mode is not defined
>     - reverse the order of patches
>     - include patch comments in all patches
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Series applied, thanks.
