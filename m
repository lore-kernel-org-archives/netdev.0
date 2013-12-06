From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: handle error more gracefully in socketpair()
Date: Thu, 05 Dec 2013 19:43:55 -0500 (EST)
Message-ID: <20131205.194355.1677309681391704143.davem@davemloft.net>
References: <1385979146-13825-1-git-send-email-ydroneaud@opteya.com>
	<20131205.162333.1525865133149454763.davem@davemloft.net>
	<1386285331.18074.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
To: ydroneaud@opteya.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386285331.18074.47.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yann Droneaud <ydroneaud@opteya.com>
Date: Fri, 06 Dec 2013 00:15:31 +0100

> AFAIK, using sys_close() seems to be the exception, and writing the file
> descriptor before installing it is the more or less the norm.

What other system call in the kernel writes a file descriptor's value
into the address space of a user process before the file descriptor
is actually usable?

That's really terrible semantically.
