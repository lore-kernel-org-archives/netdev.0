From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v2 1/3] ip: add ip sr command to
 control SR-IPv6 internal structures
Date: Sun, 16 Apr 2017 10:22:27 -0700
Message-ID: <20170416102227.2356400e@xeon-e3>
References: <20170415101717.18730-1-david.lebrun@uclouvain.be>
        <20170415101717.18730-2-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35547 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756061AbdDPRWf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 13:22:35 -0400
Received: by mail-pf0-f182.google.com with SMTP id i5so57094477pfc.2
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2017 10:22:35 -0700 (PDT)
In-Reply-To: <20170415101717.18730-2-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Overall, this looks fine and applied.
I had to add seg6.h to include/linux since it was not there.

> +		switch (alg_id) {
> +		case SEG6_HMAC_ALGO_SHA1:
> +			algstr = "sha1";
> +			break;
> +		case SEG6_HMAC_ALGO_SHA256:
> +			algstr = "sha256";
> +			break;
> +		default:
> +			algstr = "<unknown>";
> +		}

You might want to consider having a table of HMAC algorithms so that get and set match. 
It seems likely that new  values will come.
