From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/5] net: Do not record sender_cpu as napi_id
 in socket receive paths
Date: Thu, 16 Mar 2017 19:57:28 -0700
Message-ID: <1489719448.28631.279.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
         <20170316183238.15806.14293.stgit@localhost.localdomain>
         <1489701936.28631.249.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UcHgdb0Z_KvjPJuS1gtcFEi8rj2dKouUeXkuvwjopDiBQ@mail.gmail.com>
         <1489704618.28631.267.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UeTRNxb9B5Y7mhZ4QmKrUNSYDHBbQu6=kM+6X6ETuRu8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33677 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752379AbdCQDGo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:06:44 -0400
In-Reply-To: <CAKgT0UeTRNxb9B5Y7mhZ4QmKrUNSYDHBbQu6=kM+6X6ETuRu8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-16 at 19:40 -0700, Alexander Duyck wrote:

> What I probably can do is go through and replace all the spots where
> we where checking for sk_napi_id being 0, and instead replace it with
> a check against NR_CPUS.

This seems a good idea.
