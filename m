From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: diag: make udp_diag_destroy work for
 mapped addresses.
Date: Wed, 07 Sep 2016 06:35:46 -0700
Message-ID: <1473255346.10725.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473223115-144755-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ek@google.com, davem@davemloft.net,
        dsa@cumulusnetworks.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35906 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756903AbcIGNgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 09:36:24 -0400
Received: by mail-pf0-f171.google.com with SMTP id 128so6831703pfb.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 06:35:48 -0700 (PDT)
In-Reply-To: <1473223115-144755-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-07 at 13:38 +0900, Lorenzo Colitti wrote:
> udp_diag_destroy does look up the IPv4 UDP hashtable for mapped
> addresses, but it gets the IPv4 address to look up from the
> beginning of the IPv6 address instead of the end.
> 
> Tested: https://android-review.googlesource.com/269874
> Fixes: 5d77dca82839 ("net: diag: support SOCK_DESTROY for UDP sockets")
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
