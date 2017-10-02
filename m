From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 0/3] Check user supplied interface name lengths
Date: Mon, 2 Oct 2017 12:18:09 +0200
Message-ID: <20171002101809.GK32305@orbyte.nwl.cc>
References: <20170926163548.24347-1-phil@nwl.cc>
 <20170927084249.0591ee3a@shemminger-XPS-13-9360>
 <20170927160528.GN32305@orbyte.nwl.cc>
 <20170929103107.456efb11@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45932 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750949AbdJBKSK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 06:18:10 -0400
Content-Disposition: inline
In-Reply-To: <20170929103107.456efb11@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 10:31:07AM -0700, Stephen Hemminger wrote:
[...]
> I was thinking something like:
> 
> 
> 
> diff --git a/include/utils.h b/include/utils.h
> index c9ed230b9604..e2702b56f2e0 100644
> --- a/include/utils.h
> +++ b/include/utils.h
> @@ -105,6 +105,8 @@ int get_be64(__be64 *val, const char *arg, int base);
>  int get_be32(__be32 *val, const char *arg, int base);
>  int get_be16(__be16 *val, const char *arg, int base);
>  int get_addr64(__u64 *ap, const char *cp);
> +int check_ifname(const char *arg);
> +int get_ifname(char *buf, const char *arg);

Ah, understood. I'll change my patch accordingly.

Thanks, Phil
