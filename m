From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v2 2/3] iproute_lwtunnel: Argument to strerror
 must be positive
Date: Fri, 18 Aug 2017 09:21:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005A7C8@AcuExch.aculab.com>
References: <20170817170932.24812-1-phil@nwl.cc>
 <20170817170932.24812-3-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:51764 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751801AbdHRJVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 05:21:40 -0400
In-Reply-To: <20170817170932.24812-3-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 17 August 2017 18:10
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/iproute_lwtunnel.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
> index 398ab5e077ed8..1a3dc4d4c0ed9 100644
> --- a/ip/iproute_lwtunnel.c
> +++ b/ip/iproute_lwtunnel.c
> @@ -643,7 +643,7 @@ static int lwt_parse_bpf(struct rtattr *rta, size_t len,
>  	err = bpf_parse_common(bpf_type, &cfg, &bpf_cb_ops, &x);
>  	if (err < 0) {
>  		fprintf(stderr, "Failed to parse eBPF program: %s\n",
> -			strerror(err));
> +			strerror(-err));

If we are in userspace I'd expect errno values to be +ve.
Returning a -ve errno is very non-standard.

	David
