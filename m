From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/3] AFS: Implement basic file write support
Date: Wed, 09 May 2007 12:07:39 +0100
Message-ID: <4815.1178708859@redhat.com>
References: <20070509034135.853ae84c.akpm@linux-foundation.org>  <20070508170051.eb4751ce.akpm@linux-foundation.org> <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com> <20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com> <997.1178706347@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070509034135.853ae84c.akpm@linux-foundation.org> 
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:

> set_page_dirty() will set I_DIRTY_PAGES only.  ie: the inode has dirty
> pagecache data.
> 
> To tell the VFS that the inode itself is dirty one needs to run
> mark_inode_dirty().

But what's the difference in this case?  I don't need to write the inode back
per se, and the inode attributes can be updated by the mechanism of data
storage.

David
