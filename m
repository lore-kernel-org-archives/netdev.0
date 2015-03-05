From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/8] ipv4/fib_trie: Cleanups to prepare for
 introduction of key vector
Date: Wed, 04 Mar 2015 23:37:08 -0500 (EST)
Message-ID: <20150304.233708.2028588703939561424.davem@davemloft.net>
References: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbbCEEhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:37:10 -0500
In-Reply-To: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 04 Mar 2015 14:57:55 -0800

> This patch series is meant to mostly just clean up the fib_trie to prepare
> it for the introduction of the key_vector.  As such there are a number of
> minor clean-ups such as reformatting the tnode to match the format once the
> key vector is introduced, some optimizations to drop the need for a leaf
> parent pointer, and some changes to remove duplication of effort such as
> the 2 look-ups that were essentially being done per node insertion.
> 
> v2: Added code to cleanup idx >> n->bits and explain unsigned long logic
>     Added code to prevent allocation when tnode size is larger than size_t

Looks good, series applied, thanks Alex.
