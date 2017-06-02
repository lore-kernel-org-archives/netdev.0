From: Peter Dawson <petedaws@gmail.com>
Subject: Re: [PATCH net] ip6_tunnel: fix traffic class routing for tunnels
Date: Fri, 2 Jun 2017 16:03:48 +1000
Message-ID: <20170602160348.02352bce@udesktop>
References: <91e31c60-5994-6784-cfe8-6a18016c6524@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        peter.a.dawson@boeing.com
To: Liam McBirnie <mcbirnie.l@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34427 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbdFBGEB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 02:04:01 -0400
Received: by mail-pf0-f193.google.com with SMTP id w69so11491184pfk.1
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 23:04:01 -0700 (PDT)
In-Reply-To: <91e31c60-5994-6784-cfe8-6a18016c6524@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Jun 2017 15:12:26 +1000
Liam McBirnie <mcbirnie.l@gmail.com> wrote:

> The traffic class is added here because only route lookup needs the
> flowlabel to contain the traffic class.
> 
> Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on encapsulated packets")
> Signed-off-by: Liam McBirnie <liam.mcbirnie@boeing.com>

Concur with this patch. Testing that I performed on Commit: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on encapsulated packets") did not cover the case were DSCP-based routing policy is applied to the tunneled packets. 

Acked-by: Peter Dawson <peter.a.dawson@boeing.com>
