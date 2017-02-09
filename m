From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: fix a potential panic in first_packet_length()
Date: Thu, 09 Feb 2017 09:54:20 -0800
Message-ID: <1486662860.7793.106.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486654229.7793.100.camel@edumazet-glaptop3.roam.corp.google.com>
         <1486659678.2591.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36758 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751852AbdBIRyZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:54:25 -0500
Received: by mail-pg0-f65.google.com with SMTP id 75so855743pgf.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:54:21 -0800 (PST)
In-Reply-To: <1486659678.2591.11.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-09 at 18:01 +0100, Paolo Abeni wrote:
>  
> 
> My bad, I missed completely that call path.
> 
> I'm wondering if calling first_packet_length() for l2tp_ip sockets
> makes sense ?!? Am I missing something or it touches udp stats and
> checks udp csum for non udp packets ?!?

Yes, I guess this is a good point.

I will send a v2, thanks.
