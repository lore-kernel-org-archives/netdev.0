From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] netfilter: fix two recent sysctl problems
Date: Wed, 6 Aug 2008 04:22:01 +0100
Message-ID: <20080806032201.GN28946@ZenIV.linux.org.uk>
References: <489915af.VNn/ufBuUNr78bc1%ole@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Piotr Oledzki <ole@ans.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <489915af.VNn/ufBuUNr78bc1%ole@ans.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 06, 2008 at 05:08:31AM +0200, Krzysztof Piotr Oledzki wrote:
> netfilter: fix two recent sysctl problems
> 
> Starting with 9043476f726802f4b00c96d0c4f418dde48d1304 we have two
> netfilter releated problems:
> 
>  - WARNING: at kernel/sysctl.c:1966 unregister_sysctl_table+0xcc/0x103(),
>    caused by wrong order of ini/fini calls
> 
>  - net.netfilter is duplicated and has truncated set of records
> 
> Thanks to very useful guidelines from Al Viro, this patch fixes both of them.
> 
> Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>

ACKed-by: Al Viro <viro@zeniv.linux.org.uk>
