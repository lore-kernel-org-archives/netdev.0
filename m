From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Sun, 08 May 2011 21:13:41 -0700 (PDT)
Message-ID: <20110508.211341.226779345.davem@davemloft.net>
References: <20110509134613.bcf0b017.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110509134613.bcf0b017.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 9 May 2011 13:46:13 +1000

> Hi all,
> 
> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> produced this warning:
> 
> net/sctp/protocol.c: In function 'sctp_v4_xmit':
> net/sctp/protocol.c:842: warning: format '%p' expects type 'void *', but argument 5 has type '__be32'
> net/sctp/protocol.c:842: warning: format '%p' expects type 'void *', but argument 6 has type '__be32'
> 
> Caused by commit f1c0a276ea17 ("sctp: Don't use rt->rt_{src,dst} in
> sctp_v4_xmit()").

I'll fix this, thanks for the report Stephen.
