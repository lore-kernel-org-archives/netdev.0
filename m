From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] tcp: accept RST for rcv_nxt - 1 after receiving a
 FIN
Date: Fri, 13 Jan 2017 10:17:56 -0800
Message-ID: <1484331476.13165.43.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483652008-20255-1-git-send-email-jbaron@akamai.com>
         <1484149690.21472.53.camel@edumazet-glaptop3.roam.corp.google.com>
         <10070e29-2278-8df4-4abb-61a16895dfa4@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35915 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750927AbdAMSR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 13:17:58 -0500
Received: by mail-pf0-f194.google.com with SMTP id b22so9322941pfd.3
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 10:17:58 -0800 (PST)
In-Reply-To: <10070e29-2278-8df4-4abb-61a16895dfa4@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 12:28 -0500, Jason Baron wrote:
> i,
> 
> (Re-sending - seems like my reply was lost)
> 
> I wanted to define this condition as narrowly as I could. I'm ok
> dropping it -
> I'm not sure its going to make much difference in practice. So to that end,
> dropping this extra check makes sense.
> 
> I posted this as RFC because RFC 5961, I don't think says anything about
> accepting rcv_nxt - 1 in this case, so I was wondering what people
> thought...

This seems a reasonable trade-off to me

( to the rescue : RFC 1122 1.2.2 )
