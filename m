From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/6] Per-net and on-demand link indices (and related)
 v2
Date: Mon, 06 Aug 2012 18:13:06 +0400
Message-ID: <501FD0F2.4040609@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47755 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756325Ab2HFONP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 10:13:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set tries to summarize the recent discussion of making ifindices friendly
to checkpoint-restore and consists of:

1. Prepare hash function to non-unique ifindices
2. Allow for specifying the desired ifindex on net link creation
3. Make ifindex generation per-net
4. Simplify loopback device ifindex access

Changes since v1:

* Fixed a stupid mistake with a pointer bits shift
* Turned the netdev_hash_mix routine into the generic ptr_hash_mix one
* Added a comment describing why loopback index is always 1 after the patch

Thanks,
Pavel
