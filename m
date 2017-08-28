From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 1/2] iproute: add support for seg6
 l2encap mode
Date: Mon, 28 Aug 2017 12:07:24 -0700
Message-ID: <20170828120724.53904cbf@xeon-e3>
References: <20170828190525.15655-1-david.lebrun@uclouvain.be>
        <20170828190525.15655-2-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35470 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbdH1TH1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:07:27 -0400
Received: by mail-pf0-f182.google.com with SMTP id g13so3751624pfm.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:07:27 -0700 (PDT)
In-Reply-To: <20170828190525.15655-2-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 20:05:24 +0100
David Lebrun <david.lebrun@uclouvain.be> wrote:

>  
> +static const char *format_seg6mode_type(int mode)
> +{
> +	if (mode == SEG6_IPTUN_MODE_ENCAP)
> +		return "encap";
> +	else if (mode == SEG6_IPTUN_MODE_INLINE)
> +		return "inline";
> +	else if (mode == SEG6_IPTUN_MODE_L2ENCAP)
> +		return "l2encap";
> +
> +	return "<unknown>";
> +}
> +
> +static int read_seg6mode_type(const char *mode)
> +{
> +	if (strcmp(mode, "encap") == 0)
> +		return SEG6_IPTUN_MODE_ENCAP;
> +	else if (strcmp(mode, "inline") == 0)
> +		return SEG6_IPTUN_MODE_INLINE;
> +	else if (strcmp(mode, "l2encap") == 0)
> +		return SEG6_IPTUN_MODE_L2ENCAP;
> +
> +	return -1;
> +}

Since these values probably will grow over time, it would make
sense to have this a name/value table.
