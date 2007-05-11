From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/2] AFS: Fix interminable loop in afs_write_back_from_locked_page()
Date: Fri, 11 May 2007 10:57:53 +0100
Message-ID: <10145.1178877473@redhat.com>
References: <20070510161946.96ff0784.akpm@linux-foundation.org> <20070510143334.19485.26042.stgit@warthog.cambridge.redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070510161946.96ff0784.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:

> More than one would expect, given that it is recommended in
> Documentation/SubmitChecklist, which everyone reads ;)

Which states incorrectly:

| 22: Newly-added code has been compiled with `gcc -W'.  This will generate
|     lots of noise, but is good for finding bugs like "warning: comparison
|     between signed and unsigned".

-W does not imply -Wsign-compare, at least not on my gcc.

David
