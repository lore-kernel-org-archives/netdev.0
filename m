From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] headers: use __aligned_xx types for userspace
Date: Fri, 18 Mar 2011 16:28:26 -0700
Message-ID: <20110318162826.5295f130.akpm@linux-foundation.org>
References: <1300474237-10980-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36348 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757585Ab1CRX22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 19:28:28 -0400
In-Reply-To: <1300474237-10980-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Mar 2011 14:50:37 -0400
Mike Frysinger <vapier@gentoo.org> wrote:

> Now that we finally have __aligned_xx exported to userspace, convert
> the headers that get exported over to the proper type.
> 

Sob.  Please don't assume that because you're on top of an issue, all
the rest of us are.

A bit of git-log grovelling turns up

: commit 79b5dc0c64d88cda3da23b2e22a5cec0964372ac
: Author: Eric Paris <eparis@redhat.com>
: Date:   Fri Oct 15 14:34:14 2010 -0700                                          
:     types.h: define __aligned_u64 and expose to userspace
:     
:     We currently have a kernel internal type called aligned_u64 which aligns
:     __u64's on 8 bytes boundaries even on systems which would normally align
:     them on 4 byte boundaries.  This patch creates a new type __aligned_u64
:     which does the same thing but which is exposed to userspace rather than
:     being kernel internal.                                                    

but that really doesn't tell us why it was merged either.  Perhaps that
came out in the followup discussion and I failed to fix the changelog.


Still, it doesn't hurt to educate people.  Please explain why we are
making this change?

>  include/linux/if_ppp.h                    |   16 ++++++++--------
>  include/linux/netfilter/nfnetlink_log.h   |    4 ++--
>  include/linux/netfilter/nfnetlink_queue.h |    4 ++--
>  include/linux/netfilter/xt_connbytes.h    |    4 ++--
>  include/linux/netfilter/xt_quota.h        |    2 +-
>  5 files changed, 15 insertions(+), 15 deletions(-)

davem stuff :)
