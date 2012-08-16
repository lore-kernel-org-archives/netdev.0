From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v3 2/3] net: netprio: fd passed in SCM_RIGHTS
 datagram not set correctly
Date: Thu, 16 Aug 2012 15:11:51 -0700 (PDT)
Message-ID: <20120816.151151.1086500546875406230.davem@davemloft.net>
References: <20120814223424.3551.21608.stgit@jf-dev1-dcblab>
	<20120814223430.3551.88909.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com
To: john.r.fastabend@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814223430.3551.88909.stgit@jf-dev1-dcblab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 14 Aug 2012 15:34:30 -0700

> A socket fd passed in a SCM_RIGHTS datagram was not getting
> updated with the new tasks cgrp prioidx. This leaves IO on
> the socket tagged with the old tasks priority.
> 
> To fix this add a check in the scm recvmsg path to update the
> sock cgrp prioidx with the new tasks value.
> 
> Thanks to Al Viro for catching this.
> 
> CC: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
