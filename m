From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 15 Sep 2016 17:45:02 -0600
Message-ID: <999f0ddb-82e4-ea07-b52a-59d08bc7816d@cumulusnetworks.com>
References: <20160913171950.GC32643@uranus>
 <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
 <20160915202219.GB1867@uranus.lan>
 <f482796f-185e-a3b7-248c-20f1f39cb459@cumulusnetworks.com>
 <20160915210126.GC1867@uranus.lan>
 <1473979691.22679.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32841 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756927AbcIOXpH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:45:07 -0400
Received: by mail-pf0-f175.google.com with SMTP id 21so10598624pfy.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 16:45:06 -0700 (PDT)
In-Reply-To: <1473979691.22679.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/16 4:48 PM, Eric Dumazet wrote:
> On Fri, 2016-09-16 at 00:01 +0300, Cyrill Gorcunov wrote:
> 
>> Here I get kicked off the server. Login back
>>
>> [cyrill@uranus ~] ssh root@pcs7 
>> Last login: Thu Sep 15 23:20:42 2016 from gateway
>> [root@pcs7 ~]# cd /home/iproute2/
>> [root@pcs7 iproute2]# misc/ss -A raw
>> State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
>> UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
>> UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
>>
>> Maybe I do something wrong for testing?
> 
> If you kill your shell, maybe /root/sock is killer as well, thus its raw
> sockets are closed.
> 
> Try to be selective in the -K , do not kill tcp sockets ?
> 
> 

I am running
   ss -aKw 'dev == red'

to kill raw sockets bound to device named 'red'.
