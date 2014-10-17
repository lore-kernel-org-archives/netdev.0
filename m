From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Move rlb table dump to procfs
Date: Fri, 17 Oct 2014 16:48:38 -0400 (EDT)
Message-ID: <20141017.164838.1035248404947187957.davem@davemloft.net>
References: <1413571313-10137-1-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, vfalico@gmail.com,
	j.vosburgh@gmail.com, linux-kernel@vger.kernel.org
To: emunson@akamai.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413571313-10137-1-git-send-email-emunson@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric B Munson <emunson@akamai.com>
Date: Fri, 17 Oct 2014 14:41:52 -0400

> Because debugfs is not net namespace aware, it is currently not
> possible to dump the RLB hash table when network namespaces are enabled.
> This patch creates a second proc file called IFNAME_rlb_table for
> bonding interfaces that use adaptive load balancing which will expose
> this table to userspace.  It also removes all the debugfs code from the
> bonding module as the RLB hash was the only entry in debugfs.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>

It's meant to be a debugging facility, which has no stable API
and is not something the user can depend upon it.

Once you move it to procfs, it's basically over and we are
stuck with this forever.

I think the intention of this meaning to be a debug facility for
developers is very clear.

I'm not applying this, sorry.
