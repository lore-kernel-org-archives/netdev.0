From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 1/2] [PATCH] net: ip, raw_diag -- Fix socket
 leaking for destroy request
Date: Wed, 2 Nov 2016 08:56:11 -0600
Message-ID: <f305eb12-4780-ca98-051f-e4d957230b9c@cumulusnetworks.com>
References: <20161102125454.694582296@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:34719 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753471AbcKBO4T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 10:56:19 -0400
Received: by mail-it0-f49.google.com with SMTP id f129so18454787itc.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 07:56:19 -0700 (PDT)
In-Reply-To: <20161102125454.694582296@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/16 6:36 AM, Cyrill Gorcunov wrote:
> In raw_diag_destroy the helper raw_sock_get returns
> with sock_hold call, so we have to put it then.
> 
> CC: David S. Miller <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Ahern <dsa@cumulusnetworks.com>
> CC: Andrey Vagin <avagin@openvz.org>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>  net/ipv4/raw_diag.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
