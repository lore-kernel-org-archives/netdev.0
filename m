From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Wed, 18 Oct 2017 14:54:06 -0700
Message-ID: <1508363646.31614.145.camel@edumazet-glaptop3.roam.corp.google.com>
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
         <efcafc22-bea6-8f01-2804-c16f69bbd448@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:50006 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdJRVyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 17:54:08 -0400
Received: by mail-it0-f49.google.com with SMTP id y15so8053067ita.4
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 14:54:08 -0700 (PDT)
In-Reply-To: <efcafc22-bea6-8f01-2804-c16f69bbd448@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-18 at 23:49 +0200, Paweł Staszewski wrote:

> How far it is from applying this to the kernel ?
> 
> So far im using this on all my servers from about 3 months now without 
> problems

It is a hack, and does not support properly bonding/team.

( If the real_dev->privflags IFF_XMIT_DST_RELEASE bit changes,
 we want to update all the vlans at the same time )

We need something more sophisticated, and I had no time to spend on
this topic recently.
