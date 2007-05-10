From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] AFS: Fix interminable loop in
 afs_write_back_from_locked_page()
Date: Thu, 10 May 2007 16:19:46 -0700
Message-ID: <20070510161946.96ff0784.akpm@linux-foundation.org>
References: <20070510143334.19485.26042.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070510143334.19485.26042.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 May 2007 15:33:34 +0100
David Howells <dhowells@redhat.com> wrote:

> Following bug was uncovered by compiling with '-W' flag:

gcc -W finds a number of fairly scary bugs.

More than one would expect, given that it is recommended in
Documentation/SubmitChecklist, which everyone reads ;)
