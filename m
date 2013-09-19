From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] stable_kernel_rules.txt: Exclude networking from stable
 rules
Date: Thu, 19 Sep 2013 23:32:41 +0200
Message-ID: <20130919213241.GB31672@electric-eye.fr.zoreil.com>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
 <20130919.135628.1201613770803318193.davem@davemloft.net>
 <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
 <1379615474.22168.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, Mikulas Patocka <mpatocka@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rob Landley <rob@landley.net>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1379615474.22168.13.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> :
[...]
> diff --git a/Documentation/stable_kernel_rules.txt b/Documentation/stable_kernel_rules.txt
> index b0714d8..a2d6da0 100644
> --- a/Documentation/stable_kernel_rules.txt
> +++ b/Documentation/stable_kernel_rules.txt
> @@ -29,6 +29,11 @@ Rules on what kind of patches are accepted, and which ones are not, into the
>  
>  Procedure for submitting patches to the -stable tree:
>  
> + - The networking tree (net/ and drivers/net/) is 'special' and doesn't
> +   follow the rules below.  Don't send or cc: patches for the -stable tree to
> +   stable@vger.kernel.org.  Don't mark them stable.  Just send the patches to
> +   netdev@vger.kernel.org and let the networking maintainer decide what to do
> +   with them.

David said "simply ask me to queue them up for -stable explicitly".

He did not say "send the patches and let me decide what to do with them".

-- 
Ueimor
