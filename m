From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Thu, 03 Aug 2017 13:18:09 +0100
Message-ID: <yw1x3798hmke.fsf@mansr.com>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
        <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
        <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr>
        <yw1xshhagexd.fsf@mansr.com>
        <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr>
        <yw1xo9rygdyu.fsf@mansr.com>
        <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr>
        <yw1xk22mgdcx.fsf@mansr.com>
        <f1554ee7-2151-1304-c5c1-35264b9be5be@free.fr>
        <71dd7987-8c43-2548-5058-51a95658da71@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:38430 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdHCMSN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 08:18:13 -0400
In-Reply-To: <71dd7987-8c43-2548-5058-51a95658da71@free.fr> (Mason's message
        of "Wed, 2 Aug 2017 22:02:24 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 02/08/2017 19:31, Mason wrote:
>
>> # iperf3 -c 172.27.64.45 -u -b 950M
>> Connecting to host 172.27.64.45, port 5201
>> [  4] local 172.27.64.1 port 55533 connected to 172.27.64.45 port 5201
>> [ ID] Interval           Transfer     Bandwidth       Total Datagrams
>> [  4]   0.00-1.00   sec   102 MBytes   858 Mbits/sec  13091  
>> [  4]   1.00-2.00   sec   114 MBytes   953 Mbits/sec  14541  
>
> 114 MB in 14541 packets => 7840 bytes per packet
> Is iperf3 sending jumbo frames??

It's probably sending fragmented packets.

-- 
Måns Rullgård
