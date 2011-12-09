From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 REPOST] xen-netfront: delay gARP until backend
 switches to Connected
Date: Fri, 09 Dec 2011 13:45:14 -0500 (EST)
Message-ID: <20111209.134514.2071890208094978847.davem@davemloft.net>
References: <1323430738-3798-1-git-send-email-lersek@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com, jeremy@goop.org,
	xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lersek@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323430738-3798-1-git-send-email-lersek@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laszlo Ersek <lersek@redhat.com>
Date: Fri,  9 Dec 2011 12:38:58 +0100

> These two together provide complete ordering. Sub-condition (1) is
> satisfied by pvops commit 43223efd9bfd.

I don't see this commit in Linus's tree, so I doubt it's valid for
me to apply this as a bug fix to my 'net' tree since the precondition
pvops commit isn't upstream as far as I can tell.

Where did you intend me to apply this patch, and how did you expect
the dependent commit to make it's way into the tree so that this
fix is complete?

BTW, you should always explicitly specificy the answers to all the
questions in the previous paragraph, otherwise (like right now) we
go back and forth wasting time establishing these facts.

The way to say which tree the patch is intended for is to specify
it in the Subject like, f.e. "[PATCH net-next v3 REPOST] ..."
