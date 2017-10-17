From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/3] dt-bindings: net: sh_eth: add R-Car Gen[12]
 fallback compatibility strings
Date: Tue, 17 Oct 2017 13:18:41 +0300
Message-ID: <c0abee19-cb52-5835-30ae-d52149ab1680@cogentembedded.com>
References: <20171017074747.24159-1-horms+renesas@verge.net.au>
 <20171017074747.24159-2-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:50673 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935072AbdJQKSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 06:18:43 -0400
Received: by mail-lf0-f54.google.com with SMTP id a132so1369882lfa.7
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 03:18:42 -0700 (PDT)
In-Reply-To: <20171017074747.24159-2-horms+renesas@verge.net.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 10:47 AM, Simon Horman wrote:

> Add fallback compatibility strings for R-Car Gen 1 and 2.
> 
> In the case of Renesas R-Car hardware we know that there are generations of
> SoCs, f.e. Gen 1 and 2. But beyond that its not clear what the relationship
> between IP blocks might be. For example, I believe that r8a7790 is older
> than r8a7791 but that doesn't imply that the latter is a descendant of the
> former or vice versa.
> 
> We can, however, by examining the documentation and behaviour of the
> hardware at run-time observe that the current driver implementation appears
> to be compatible with the IP blocks on SoCs within a given generation.
> 
> For the above reasons and convenience when enabling new SoCs a
> per-generation fallback compatibility string scheme being adopted for
> drivers for Renesas SoCs.
> 
> Note that R-Car Gen2 and RZ/G1 have many compatible IP blocks.  The
> approach that has been consistently taken for other IP blocks is to name
> common code, compatibility strings and so on after Rcar Gen2.

    R-Car here too. :-)

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

MBR, Sergei
