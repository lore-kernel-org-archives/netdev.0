From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 net] iproute: fix compilation issue with older
 glibc
Date: Fri, 16 Jun 2017 16:48:26 +0200
Message-ID: <5943EFBA.1010005@iogearbox.net>
References: <20170616135428.18262-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Lebrun <david.lebrun@uclouvain.be>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41141 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752060AbdFPOs2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 10:48:28 -0400
In-Reply-To: <20170616135428.18262-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2017 03:54 PM, David Lebrun wrote:
> If a header that includes linux/in6.h is included before
> iproute's utils.h, then iproute2 fails to compile on older
> glibc versions.
>
> Fixes: e8493916a8ede9970732e33ea52d30b83071f401 ("iproute: add support for SR-IPv6 lwtunnel encapsulation")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Works for me, thanks for fixing! ;)

Tested-by: Daniel Borkmann <daniel@iogearbox.net>
