From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/2] AFS: Fix interminable loop in afs_write_back_from_locked_page()
Date: Fri, 11 May 2007 11:03:37 +0100
Message-ID: <11025.1178877817@redhat.com>
References: <20070511025822.a5aa5240.akpm@linux-foundation.org> <20070510161946.96ff0784.akpm@linux-foundation.org> <20070510143334.19485.26042.stgit@warthog.cambridge.redhat.com> <8792.1178876963@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbXEKKDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 06:03:43 -0400
In-Reply-To: <20070511025822.a5aa5240.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:

> Yes, it's a shame that there doesn't seem to be a fine-grained way of
> turning on -W's useful bits.

You can turn off -W's undesirable bits.  For net/rxrpc/ and fs/afs/ at least,
adding:

	CFLAGS += -W -Wno-unused-parameter

to the Makefile generates no warnings.  Perhaps this should be added to the
master Makefile.

Adding -Wsign-compare finds some stuff that I will fix.  It also finds some
stuff in the main and the networking headers.  This is a really useful option
and found some tricky bugs in CacheFiles.  I would endorse adding this
generally too.

David
