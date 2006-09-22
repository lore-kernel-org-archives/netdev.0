From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.18 try 2] net/ipv4: sysctl to allow non-superuser
 to bypass CAP_NET_BIND_SERVICE requirement
Date: Fri, 22 Sep 2006 11:04:36 -0700 (PDT)
Message-ID: <20060922.110436.34753480.davem@davemloft.net>
References: <736CE60D-FB88-4246-8728-B7AC7880B28E@atheme.org>
	<20060922.164109.112537486.yoshfuji@linux-ipv6.org>
	<AD838733-3A8F-4B3E-B620-9B2284B8B2BF@atheme.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964814AbWIVSEU@vger.kernel.org>
To: nenolod@atheme.org
In-Reply-To: <AD838733-3A8F-4B3E-B620-9B2284B8B2BF@atheme.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: William Pitcock <nenolod@atheme.org>
Date: Fri, 22 Sep 2006 03:27:22 -0500

> * The software is untrusted by the end user, in the event that the  
> software is not trustworthy, the amount of damage it can do running  
> as a normal user is less than as a superuser. As it is, the bind()  
> may have failed before the CAP_NET_BIND_SERVICE capability was  
> granted to the process.

You have the power to exec() the daemon in question with
CAP_NET_BIND_SERVICE capability inherited from the parent,
and that will be the only "extra" capability the process will
have.

So there is in fact an existing mechanism for doing this.

If you have the power to set the sysctl, you have the power
to give the capability to an arbitrary process which you
want to get lower ports but do not trust to run completely
as root.
