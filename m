From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 8/8] AFS: Add security support
Date: Wed, 11 Apr 2007 15:38:44 -0400
Message-ID: <20070411193844.GC3704@fieldses.org>
References: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com> <20070411191037.15499.67852.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070411191037.15499.67852.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2007 at 08:10:37PM +0100, David Howells wrote:
> Add security support to the AFS filesystem.  Kerberos IV tickets are
> added as RxRPC keys are added to the session keyring with the klog
> program.  open() and other VFS operations then find this ticket with
> request_key() and either use it immediately (eg: mkdir, unlink) or
> attach it to a file descriptor (open).

Just curious--when is the actual crypto done?  There doesn't seem to be
any in this patch.

--b.
