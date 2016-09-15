From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 15 Sep 2016 15:48:11 -0700
Message-ID: <1473979691.22679.55.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160913171950.GC32643@uranus>
         <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
         <20160915202219.GB1867@uranus.lan>
         <f482796f-185e-a3b7-248c-20f1f39cb459@cumulusnetworks.com>
         <20160915210126.GC1867@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33192 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754907AbcIOWsP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 18:48:15 -0400
In-Reply-To: <20160915210126.GC1867@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-16 at 00:01 +0300, Cyrill Gorcunov wrote:

> Here I get kicked off the server. Login back
> 
> [cyrill@uranus ~] ssh root@pcs7 
> Last login: Thu Sep 15 23:20:42 2016 from gateway
> [root@pcs7 ~]# cd /home/iproute2/
> [root@pcs7 iproute2]# misc/ss -A raw
> State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
> UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
> UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
> 
> Maybe I do something wrong for testing?

If you kill your shell, maybe /root/sock is killer as well, thus its raw
sockets are closed.

Try to be selective in the -K , do not kill tcp sockets ?
