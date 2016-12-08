From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Thu, 08 Dec 2016 11:32:00 -0800
Message-ID: <1481225520.4930.125.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481049061.7129.18.camel@redhat.com>
         <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481051786.7129.22.camel@redhat.com>
         <1481052922.18162.605.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481093247.18162.637.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481097428.5535.12.camel@redhat.com>
         <1481120956.4930.7.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481223008.8408.6.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Tom Herbert <tom@herbertland.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34214 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752630AbcLHTdD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:33:03 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so27633898pgc.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:33:03 -0800 (PST)
In-Reply-To: <1481223008.8408.6.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 19:50 +0100, Paolo Abeni wrote:

> UDP GRO will require connected socket - very likely no DNS server. The
> use-case is an application using long lived UDP sockets doing a lot of
> traffic, like fix protocol feeds over UDP. 

You mean, the kind of traffic that should use TCP in the first place,
right ? ;)

NFS switched to TCP a long time ago.
