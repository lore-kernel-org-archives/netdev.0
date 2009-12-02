From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: use -fPIC in lib/
Date: Tue, 1 Dec 2009 16:18:40 -0800
Message-ID: <20091201161840.3cad8900@nehalam>
References: <39840bc80909201712o65b1c84m1bc453bf9d4329a@mail.gmail.com>
	<20091123100352.GA14356@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Baryshev <ksquirrel.iv@gmail.com>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43945 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754840AbZLBASz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 19:18:55 -0500
In-Reply-To: <20091123100352.GA14356@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 11:03:52 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> The static libnetlink.a library is exposed to other users in Debian via the
> "iproute-dev" package. Apparently people are interested in using it in their
> shared libraries and would like to see the code be position independent.
> 
> Patch below makes the code under lib/ build with -fPIC.
> 
> See http://bugs.debian.org/547602
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> 
> ---
> 
> Resending patch since no comments has been received and it has not
> appeared in the iproute git repository.
> 
> 
> diff --git a/lib/Makefile b/lib/Makefile
> index bc270bf..da2f0fc 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -1,3 +1,4 @@
> +CFLAGS += -fPIC
>  
>  UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
>  

ok applied

-- 
