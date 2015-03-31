From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: pad nla_memcpy dest buffer with zeroes
Date: Tue, 31 Mar 2015 14:07:54 -0400 (EDT)
Message-ID: <20150331.140754.256262715966365806.davem@davemloft.net>
References: <34fc9fcd5e67ad578fc5a1a2eb30cf52ffbba082.1427637780.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbbCaSH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 14:07:56 -0400
In-Reply-To: <34fc9fcd5e67ad578fc5a1a2eb30cf52ffbba082.1427637780.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Sun, 29 Mar 2015 16:05:28 +0200

> This is especially important in cases where the kernel allocs a new
> structure and expects a field to be set from a netlink attribute. If such
> attribute is shorter than expected, the rest of the field is left containing
> previous data. When such field is read back by the user space, kernel memory
> content is leaked.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks Jiri.
