From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: fix flow labels when the traffic class is non-0
Date: Tue, 31 Jan 2017 09:57:21 -0800
Message-ID: <1485885441.6360.119.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170130220942.19105-1-dmichail@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tom@herbertland.com, netdev@vger.kernel.org,
        edumazet@google.com
To: Dimitris Michailidis <dmichail@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33376 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751187AbdAaSF3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:05:29 -0500
Received: by mail-pf0-f196.google.com with SMTP id e4so28945243pfg.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:04:47 -0800 (PST)
In-Reply-To: <20170130220942.19105-1-dmichail@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-30 at 14:09 -0800, Dimitris Michailidis wrote:
> ip6_make_flowlabel() determines the flow label for IPv6 packets. It's
> supposed to be passed a flow label, which it returns as is if non-0 and
> in some other cases, otherwise it calculates a new value.


Acked-by: Eric Dumazet <edumazet@google.com>

Thanks.
