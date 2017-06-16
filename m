From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net] iproute: fix compilation issue with older
 glibc
Date: Fri, 16 Jun 2017 09:04:39 -0700
Message-ID: <20170616090439.525c2f9a@xeon-e3>
References: <20170616135428.18262-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36149 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdFPQEl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:04:41 -0400
Received: by mail-pf0-f175.google.com with SMTP id x63so24285941pff.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 09:04:41 -0700 (PDT)
In-Reply-To: <20170616135428.18262-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Jun 2017 15:54:28 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> If a header that includes linux/in6.h is included before
> iproute's utils.h, then iproute2 fails to compile on older
> glibc versions.
> 
> Fixes: e8493916a8ede9970732e33ea52d30b83071f401 ("iproute: add support for SR-IPv6 lwtunnel encapsulation")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Looks good, almost always best to remove #ifdef's if possible.
Applied
