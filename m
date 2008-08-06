From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: fix two recent sysctl problems
Date: Wed, 06 Aug 2008 02:35:52 -0700 (PDT)
Message-ID: <20080806.023552.21455103.davem@davemloft.net>
References: <489915af.VNn/ufBuUNr78bc1%ole@ans.pl>
	<20080806032201.GN28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ole@ans.pl, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080806032201.GN28946@ZenIV.linux.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 6 Aug 2008 04:22:01 +0100

> On Wed, Aug 06, 2008 at 05:08:31AM +0200, Krzysztof Piotr Oledzki wrote:
> > netfilter: fix two recent sysctl problems
> > 
> > Starting with 9043476f726802f4b00c96d0c4f418dde48d1304 we have two
> > netfilter releated problems:
> > 
> >  - WARNING: at kernel/sysctl.c:1966 unregister_sysctl_table+0xcc/0x103(),
> >    caused by wrong order of ini/fini calls
> > 
> >  - net.netfilter is duplicated and has truncated set of records
> > 
> > Thanks to very useful guidelines from Al Viro, this patch fixes both of them.
> > 
> > Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>
> 
> ACKed-by: Al Viro <viro@zeniv.linux.org.uk>

Applied, thanks.
