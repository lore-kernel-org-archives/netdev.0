From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Wed, 31 Aug 2016 10:11:05 -0700
Message-ID: <20160831101105.4d992d13@xeon-e3>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
        <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33337 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934320AbcHaRKz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 13:10:55 -0400
Received: by mail-pa0-f48.google.com with SMTP id cy9so20512256pac.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 10:10:54 -0700 (PDT)
In-Reply-To: <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2016 17:52:40 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> +static struct nla_policy seg6_genl_policy[SEG6_ATTR_MAX + 1] = {
> +	[SEG6_ATTR_DST]				= { .type = NLA_BINARY,
> +		.len = sizeof(struct in6_addr) },
> +	[SEG6_ATTR_DSTLEN]			= { .type = NLA_S32, },
> +	[SEG6_ATTR_HMACKEYID]		= { .type = NLA_U32, },
> +	[SEG6_ATTR_SECRET]			= { .type = NLA_BINARY, },
> +	[SEG6_ATTR_SECRETLEN]		= { .type = NLA_U8, },
> +	[SEG6_ATTR_ALGID]			= { .type = NLA_U8, },
> +	[SEG6_ATTR_HMACINFO]		= { .type = NLA_NESTED, },
> +};

Should be const?
