From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Mon, 24 Nov 2014 16:52:21 -0800
Message-ID: <20141125005221.GB21653@thin>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Bertrand Jacquin <beber@meleeweb.net>,
	Catalina Mocanu <catalina.mocanu@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Fabian Frederick <fabf@skynet.be>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel@lists.sourceforge.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Hugh Dickins <hughd@google.com>,
	Iulia Manda <iulia.manda21@gmail.com>,
	Jan Beulich <JBeulich@suse.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jeff Layton <jlayton@poochiereds.net>,
	"open list:ABI/API" <linux-api@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	open list <linux-kernel@vger.kernel.org>,
	"open
To: Pieter Smith <pieter@boesman.nl>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 12:00:59AM +0100, Pieter Smith wrote:
> REPO: https://github.com/smipi1/linux-tinification.git
> 
> BRANCH: tiny/config-syscall-splice
> 
> BACKGROUND: This patch-set forms part of the Linux Kernel Tinification effort (
>   https://tiny.wiki.kernel.org/).
> 
> GOAL: Support compiling out the splice family of syscalls (splice, vmsplice,
>   tee and sendfile) along with all supporting infrastructure if not needed.
>   Many embedded systems will not need the splice-family syscalls. Omitting them
>   saves space.
> 
> HISTORY:
>   PATCH v4:
>     - Drops __splice_p()
>     - Let nfsd fall back to non-splice support when splice is compiled out
>     - Style fixes
[...]
> RESULTS: A tinyconfig bloat-o-meter score for the entire patch-set:
> 
> add/remove: 0/41 grow/shrink: 5/7 up/down: 23/-8422 (-8399)

I replied to one patch with a minor nit in the commit message.  Other
than that, I don't see any obvious issues with this.

- Josh Triplett
