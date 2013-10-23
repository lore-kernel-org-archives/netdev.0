From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter fixes for net
Date: Wed, 23 Oct 2013 16:56:32 -0400 (EDT)
Message-ID: <20131023.165632.1355159920749130897.davem@davemloft.net>
References: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 23 Oct 2013 11:15:21 +0200

> The following patchset contains three netfilter fixes for your net
> tree, they are:
> 
> * A couple of fixes to resolve info leak to userspace due to uninitialized
>   memory area in ulogd, from Mathias Krause.
> 
> * Fix instruction ordering issues that may lead to the access of
>   uninitialized data in x_tables. The problem involves the table update
>  (producer) and the main packet matching (consumer) routines. Detected in
>   SMP ARMv7, from Will Deacon.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo.
