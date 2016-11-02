From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 2/2] [PATCH] net: ip, raw_diag -- Use jump for
 exiting from nested loop
Date: Wed, 2 Nov 2016 08:56:26 -0600
Message-ID: <46419696-e2bc-7ff9-0911-e63a4b63bc63@cumulusnetworks.com>
References: <20161102125454.754267793@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:35296 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752165AbcKBO50 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 10:57:26 -0400
Received: by mail-it0-f54.google.com with SMTP id e187so85254752itc.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 07:57:26 -0700 (PDT)
In-Reply-To: <20161102125454.754267793@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/16 6:36 AM, Cyrill Gorcunov wrote:
> I managed to miss that sk_for_each is called under "for"
> cycle so need to use goto here to return matching socket.
> 
> CC: David S. Miller <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Ahern <dsa@cumulusnetworks.com>
> CC: Andrey Vagin <avagin@openvz.org>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>  net/ipv4/raw_diag.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
