From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Thu, 21 Sep 2017 15:07:11 -0700
Message-ID: <7dbc2dd1-eec9-0bd3-7255-4fe6026847aa@gmail.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
 <20170812142358.08291888@redhat.com>
 <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
 <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
 <20170814181957.5be27906@redhat.com> <1502729870.8411.63.camel@redhat.com>
 <80b3bf71-dc6b-7b96-43d6-dbb3c53c5a8b@itcare.pl>
 <1502759225.4936.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <1502759849.4936.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <4b1efff7-4f91-fd78-beb8-2c7ebcf18895@itcare.pl>
 <5d32f5cf-ca69-1f6b-5bca-cdcd4dc414e2@itcare.pl>
 <6607c631-580d-825b-6205-6f6ee688ce32@gmail.com>
 <1506030895.29839.153.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Paolo Abeni <pabeni@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:55149 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:07:14 -0400
Received: by mail-qt0-f177.google.com with SMTP id i13so7376113qtc.11
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 15:07:14 -0700 (PDT)
In-Reply-To: <1506030895.29839.153.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2017 02:54 PM, Eric Dumazet wrote:
> On Thu, 2017-09-21 at 14:41 -0700, Florian Fainelli wrote:
> 
>> Would not this apply to pretty much any stacked device setup though? It
>> seems like any network device that just queues up its packet on another
>> physical device for actual transmission may need that (e.g: DSA, bond,
>> team, more.?)
> 
> We support bonding and team already.

Right, so that seems to mostly leave us with DSA at least. What about
other devices that also have IFF_NO_QUEUE set?
-- 
Florian
