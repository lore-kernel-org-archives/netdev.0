From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter fixes for net
Date: Mon, 27 Feb 2017 09:19:05 -0500 (EST)
Message-ID: <20170227.091905.1512965295695328615.davem@davemloft.net>
References: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 27 Feb 2017 12:35:36 +0100

> The following patchset contains netfilter fixes for you net tree,
> they are:
> 
> 1) Missing ct zone size in the nft_ct initialization path, patch
>    from Florian Westphal.
> 
> 2) Two patches for netfilter uapi headers, one to remove unnecessary
>    sysctl.h inclusion and another to fix compilation of xt_hashlimit.h
>    in userspace, from Dmitry V. Levin.
> 
> 3) Patch to fix a sloppy change in nf_ct_expect that incorrectly
>    simplified nf_ct_expect_related_report() in the previous nf-next
>    batch. This also includes another patch for __nf_ct_expect_check()
>    to report success by returning 0 to keep it consistent with other
>    existing functions. From Jarno Rajahalme.
> 
> 4) The ->walk() iterator of the new bitmap set type goes over the real
>    bitmap size, this results in incorrect dumps when NFTA_SET_USERDATA
>    is used.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
