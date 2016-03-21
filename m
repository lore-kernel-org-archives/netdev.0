From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: fix sparse warnings
Date: Mon, 21 Mar 2016 13:30:24 -0400 (EDT)
Message-ID: <20160321.133024.783333130148685527.davem@davemloft.net>
References: <c100b5ed75967714ab32287f37d250b729753282.1458578309.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756703AbcCURaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 13:30:25 -0400
In-Reply-To: <c100b5ed75967714ab32287f37d250b729753282.1458578309.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Mon, 21 Mar 2016 17:39:18 +0100

> Sparse reports false positives for the header manipulation inlines. Annotate
> them correctly.
> 
> Tested by sparse on a little endian and big endian machine.
> 
> Fixes: 54bfd872bf16d ("vxlan: keep flags and vni in network byte order")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks Jiri.

> As a side note, I tried to simplify all of these functions by using nested
> be32_to_cpu(cpu_to_be32()) calls but GCC seems not to be clever enough to
> optimize the byteswaps out.

Ok, thanks for the note, thanks again.
