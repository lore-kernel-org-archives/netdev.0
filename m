From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Make XFRM optional
Date: Mon, 4 Aug 2003 11:45:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030804114507.6e496c77.davem@redhat.com>
References: <20030804125022.GA8167@averell>
	<20030804.215801.124854897.yoshfuji@linux-ipv6.org>
	<20030804130408.GA36367@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, ak@muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@colin2.muc.de>
In-Reply-To: <20030804130408.GA36367@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 4 Aug 2003 15:04:08 +0200
Andi Kleen <ak@colin2.muc.de> wrote:

> Thanks for the feedback. Here is a new patch with the two hunks 
> removed.

Still broken in two areas:

1) You moved inet_peer_idlock into net/xfrm/xfrm_exports.c, that
   looks quite wrong.

2) Your patch doesn't apply to Linus's current tree because
   "secpath_dup" got added to net/netsyms.c since 2.6.0-test2 got
   released.

I wanted to merge this, but I can't until you fix the above problems.

Thanks.
