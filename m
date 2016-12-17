From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] GTP tunneling fixes for net
Date: Sat, 17 Dec 2016 12:01:01 -0500 (EST)
Message-ID: <20161217.120101.1563401776936155851.davem@davemloft.net>
References: <1481837753-10317-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        laforge@gnumonks.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481837753-10317-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 15 Dec 2016 22:35:51 +0100

> The following patchset contains two GTP tunneling fixes for your net
> tree, they are:
> 
> 1) Offset to IPv4 header in gtp_check_src_ms_ipv4() is incorrect, thus
>    this function always succeeds and therefore this defeats this sanity
>    check. This allows packets that have no PDP to go though, patch from
>    Lionel Gauthier.
> 
> 2) According to Note 0 of Figure 2 in Section 6 of 3GPP TS 29.060 v13.5.0
>    Release 13, always set GTPv1 reserved bit to zero. This may cause
>    interoperability problems, patch from Harald Welte.
> 
> Please, apply, thanks a lot!

Series applied, thanks Pablo.
