From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/2] AFS: Fix interminable loop in afs_write_back_from_locked_page()
Date: Fri, 11 May 2007 10:49:23 +0100
Message-ID: <8792.1178876963@redhat.com>
References: <20070510161946.96ff0784.akpm@linux-foundation.org> <20070510143334.19485.26042.stgit@warthog.cambridge.redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755453AbXEKJtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 05:49:31 -0400
In-Reply-To: <20070510161946.96ff0784.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:

> > Following bug was uncovered by compiling with '-W' flag:
> 
> gcc -W finds a number of fairly scary bugs.

Do you mean in my code specifically?  Or in the kernel in general?  As far as
I can tell -W only finds an eye-glazingly large quantity of 'unused parameter'
warnings in AFS and AF_RXRPC.

David
