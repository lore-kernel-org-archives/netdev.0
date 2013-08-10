From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netfilter fixes for 3.11-rc4
Date: Sat, 10 Aug 2013 13:44:50 -0700 (PDT)
Message-ID: <20130810.134450.2199692509367745432.davem@davemloft.net>
References: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 10 Aug 2013 18:58:49 +0200

> The following patchset contains four netfilter fixes, they are:
> 
> * Fix possible invalid access and mangling of the TCPMSS option in
>   xt_TCPMSS. This was spotted by Julian Anastasov.
> 
> * Fix possible off by one access and mangling of the TCP packet in
>   xt_TCPOPTSTRIP, also spotted by Julian Anastasov.
> 
> * Fix possible information leak due to missing initialization of one
>   padding field of several structures that are included in nfqueue and
>   nflog netlink messages, from Dan Carpenter.
> 
> * Fix TCP window tracking with Fast Open, from Yuchung Cheng.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo!
