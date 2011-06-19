From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] proc: Usable inode numbers for the namespace file
 descriptors.
Date: Sun, 19 Jun 2011 16:22:18 -0700 (PDT)
Message-ID: <20110619.162218.1110628316477222542.davem@davemloft.net>
References: <20110523014751.GB2351982@jupiter.n2.diac24.net>
	<m1wrgkavbm.fsf_-_@fess.ebiederm.org>
	<m1mxhgav9c.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, adobriyan@gmail.com,
	netdev@vger.kernel.org, equinox@diac24.net,
	linux-kernel@vger.kernel.org, serge@hallyn.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1mxhgav9c.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 17 Jun 2011 16:33:19 -0700

> 
> Assign a unique proc inode to each namespace, yielding an
> identifier that userspace can use for identifying a namespace.
> 
> This has been a long requested feature and only blocked because
> a naive implementation would put the id in a global space and
> would ultimately require having a namespace for the names of
> namespaces, making migration and certain virtualization tricks
> impossible.
> 
> We still don't have per superblock inode numbers for proc, which
> appears necessary for application unaware checkpoint/restart and
> migrations (if the application is using namespace filedescriptors)
> but that is now allowd by the design if it becomes important.
> 
> I have preallocated the ipc and uts initial proc inode numbers so
> their structures can be statically initialized.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

For networking bits:

Acked-by: David S. Miller <davem@davemloft.net>
