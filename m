From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC ipsec-next 2/2] xfrm: Add a device independent napi
 instance
Date: Thu, 26 Jan 2017 07:10:22 -0800
Message-ID: <1485443422.5145.132.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485413456-31197-1-git-send-email-steffen.klassert@secunet.com>
         <1485413456-31197-3-git-send-email-steffen.klassert@secunet.com>
         <1485440767.5145.126.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35233 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752650AbdAZPK0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 10:10:26 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so16644400pfa.2
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 07:10:26 -0800 (PST)
In-Reply-To: <1485440767.5145.126.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-26 at 06:26 -0800, Eric Dumazet wrote:

> 
> Alternative would be to use a 
> 
> static struct net_device xfrm_napi_anchor_device;
> 
> and use gro_cell

Also take a look at init_dummy_netdev()

Thanks !
