From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC ipsec-next 2/2] xfrm: Add a dummy network device for
 napi.
Date: Fri, 27 Jan 2017 06:46:38 -0800
Message-ID: <1485528398.6360.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485501572-20908-1-git-send-email-steffen.klassert@secunet.com>
         <1485501572-20908-3-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35428 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755097AbdA0Oqk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 09:46:40 -0500
Received: by mail-pg0-f68.google.com with SMTP id 204so25174298pge.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 06:46:40 -0800 (PST)
In-Reply-To: <1485501572-20908-3-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-27 at 08:19 +0100, Steffen Klassert wrote:
> This patch adds a dummy network device so that we can
> use gro_cells for IPsec GRO. With this, we handle IPsec
> GRO with no impact on the generic networking code.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/xfrm/xfrm_input.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)

That is nice ;)
