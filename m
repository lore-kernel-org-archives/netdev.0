From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/24] sysctl: cookie: pass ctl_header_cookie to
 proc_handler
Date: Wed, 06 Apr 2011 12:54:56 -0700 (PDT)
Message-ID: <20110406.125456.245400506.davem@davemloft.net>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
	<cover.1301711868.git.lucian.grijincu@gmail.com>
	<2c7dffeffbbb6cc768816a904a1dde2d969a1c4e.1301711868.git.lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, ebiederm@xmission.com, tavi@cs.pub.ro,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: lucian.grijincu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2c7dffeffbbb6cc768816a904a1dde2d969a1c4e.1301711868.git.lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date: Sat,  2 Apr 2011 04:53:17 +0200

> The bulk of this patch changes all proc_handlers in the kernel to
> receive the cookie.
> 
> Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>

Since this stuff is pretty invasive outside of the networking I really
need to see two things:

1) Feedback from sysctl folks.

2) Some coordination with whoever maintains sysctl stuff so we can
   decide how to stage these changes in various maintainer trees,
   including mine.
