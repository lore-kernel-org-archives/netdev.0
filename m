From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 8/8] AFS: Add security support
Date: Wed, 11 Apr 2007 16:17:36 -0400
Message-ID: <20070411201736.GD3704@fieldses.org>
References: <20070411193844.GC3704@fieldses.org> <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com> <20070411191037.15499.67852.stgit@warthog.cambridge.redhat.com> <18379.1176322232@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <18379.1176322232@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2007 at 09:10:32PM +0100, David Howells wrote:
> J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > Just curious--when is the actual crypto done?  There doesn't seem to be
> > any in this patch.
> 
> See AF_RXRPC patch:
> 
> 	http://people.redhat.com/~dhowells/rxrpc/04-af_rxrpc.diff
> 
> You turn on CONFIG_RXKAD and load the rxkad module thus built (assuming you
> haven't built it in) after loading the af_rxrpc module.  I probably should've
> mentioned that in the cover.

Oh, I see--didn't think to check net/rxrpc.  Thanks!

--b.
