From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] AFS: Implement basic file write support
Date: Wed, 9 May 2007 09:28:53 -0700
Message-ID: <20070509092853.65619a35.akpm@linux-foundation.org>
References: <20070509034135.853ae84c.akpm@linux-foundation.org>
	<20070508170051.eb4751ce.akpm@linux-foundation.org>
	<20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com>
	<20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
	<997.1178706347@redhat.com>
	<4815.1178708859@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:53286 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756037AbXEIQ3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 12:29:03 -0400
In-Reply-To: <4815.1178708859@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 May 2007 12:07:39 +0100 David Howells <dhowells@redhat.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > set_page_dirty() will set I_DIRTY_PAGES only.  ie: the inode has dirty
> > pagecache data.
> > 
> > To tell the VFS that the inode itself is dirty one needs to run
> > mark_inode_dirty().
> 
> But what's the difference in this case?  I don't need to write the inode back
> per se, and the inode attributes can be updated by the mechanism of data
> storage.
> 

Ah.  Well if you don't need to write the inode back then sure, there
shouldn't be a need to mark it dirty.  That's what I was asking ;)

