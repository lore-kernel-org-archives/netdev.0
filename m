From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 01 Oct 2012 20:22:29 +0100
Message-ID: <5069ED75.9030801@googlemail.com>
References: <1348779826.5093.1750.camel@edumazet-glaptop> <1348780624.5093.1767.camel@edumazet-glaptop> <50656C4A.8090302@googlemail.com> <1348831592.5093.2251.camel@edumazet-glaptop> <5068648C.7050005@googlemail.com> <1349034330.12401.210.camel@edumazet-glaptop> <506955F3.8050304@googlemail.com> <1349082950.12401.669.camel@edumazet-glaptop> <5069B300.9080308@googlemail.com> <1349105498.12401.706.camel@edumazet-glaptop> <20121001183452.GA4492@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Captain Obvious <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62917 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab2JATW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 15:22:28 -0400
Received: by eaac13 with SMTP id c13so1917772eaa.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 12:22:27 -0700 (PDT)
In-Reply-To: <20121001183452.GA4492@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/01/12 19:34, Captain Obvious wrote:
> Eric Dumazet <eric.dumazet@gmail.com> :
> [...]
>>>> Could you send
>>>>
>>>> iptables -t -nat -nvL
>>>
>>> $ iptables -t -nat -nvL
>                    ^ typo
>
> Please try "iptables -t nat -nvL" as was also suggested.
>

Good catch, Captain. Thanks.

$ iptables -t nat -nvL
Chain PREROUTING (policy ACCEPT 58 packets, 7716 bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain INPUT (policy ACCEPT 41 packets, 5895 bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain OUTPUT (policy ACCEPT 1158 packets, 75559 bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain POSTROUTING (policy ACCEPT 208 packets, 14279 bytes)
  pkts bytes target     prot opt in     out     source 
destination
   951 61351 MASQUERADE  all  --  *      eth0    0.0.0.0/0 
0.0.0.0/0
