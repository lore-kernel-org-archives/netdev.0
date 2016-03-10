From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/5] vti6: Fix dst_entry leek on pmtu discovery
Date: Thu, 10 Mar 2016 16:52:57 +0300
Message-ID: <56E17C39.6010703@cogentembedded.com>
References: <1457605469-17332-1-git-send-email-steffen.klassert@secunet.com>
 <1457605469-17332-5-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34168 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbcCJNxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 08:53:15 -0500
Received: by mail-lb0-f179.google.com with SMTP id xr8so109069547lbb.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 05:53:15 -0800 (PST)
In-Reply-To: <1457605469-17332-5-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

    s/leek/leak/ in the subject.

On 3/10/2016 1:24 PM, Steffen Klassert wrote:
> We may exit without releasing the dst_entry on pmtu discovery,
> so don't return directly but goto the te error handling. This

    Te?

> also makes sure that the statistic counter gets updated.
>
> Fixes: ccd740cbc6e0 ("vti6: Add pmtu handling to vti6_xmit.")
> Reported-by: Mark McKinstry <Mark.McKinstry@alliedtelesis.co.nz>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
[...]

MBR, Sergei
