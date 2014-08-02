From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Netfilter/IPVS fixes for net
Date: Sat, 02 Aug 2014 16:49:46 -0700 (PDT)
Message-ID: <20140802.164946.1059611435908084703.davem@davemloft.net>
References: <1406911239-6250-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1406911239-6250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri,  1 Aug 2014 18:40:36 +0200

> The following patchset contains Netfilter/IPVS fixes for your net tree,
> they are:
> 
> 1) Maintain all DSCP and ECN bits for IPv6 tun forwarding. This
>    resolves an inconsistency between IPv4 and IPv6 behaviour.
>    Patch from Alex Gartrell via Simon Horman.
> 
> 2) Fix unnoticeable blink in xt_LED when the led-always-blink option is
>    used, from Jiri Prchal.
> 
> 3) Add missing return in nft_del_setelem(), otherwise this results in a
>    double call of nft_data_uninit() in the nf_tables code, from Thomas Graf.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
