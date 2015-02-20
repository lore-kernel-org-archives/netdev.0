From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 2/3] rhashtable: better high order allocation attempts
Date: Fri, 20 Feb 2015 12:01:20 +0000
Message-ID: <20150220120120.GC4586@casper.infradead.org>
References: <cover.1424389682.git.daniel@iogearbox.net>
 <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, johunt@akamai.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51387 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbbBTMBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 07:01:22 -0500
Content-Disposition: inline
In-Reply-To: <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/15 at 12:53am, Daniel Borkmann wrote:
> When trying to allocate future tables via bucket_table_alloc(), it seems
> overkill on large table shifts that we probe for kzalloc() unconditionally
> first, as it's likely to fail.
> 
> Only probe with kzalloc() for more reasonable table sizes and use vzalloc()
> either as a fallback on failure or directly in case of large table sizes.
> 
> Fixes: 7e1e77636e36 ("lib: Resizable, Scalable, Concurrent Hash Table")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Thomas Graf <tgraf@suug.ch>
