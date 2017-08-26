From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP sockets oddities
Date: Fri, 25 Aug 2017 22:20:43 -0700
Message-ID: <1503724843.11498.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3fed7679-0e19-8a0a-eee6-11baa5654fac@gmail.com>
         <1503527210.2499.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <9a9c1c94-4902-2ec9-d216-3f5cfb3044af@gmail.com>
         <1503529476.2499.65.camel@edumazet-glaptop3.roam.corp.google.com>
         <6c88e440-3f36-858d-1a08-bd32a2c66f4e@gmail.com>
         <1503535426.2499.66.camel@edumazet-glaptop3.roam.corp.google.com>
         <4adb4b66-590c-c55a-44aa-27dd409ce14f@gmail.com>
         <3c44d27e-27d9-e9c4-04b3-17c0366e60d9@gmail.com>
         <1503705440.11498.9.camel@edumazet-glaptop3.roam.corp.google.com>
         <ce4af8cc-3de1-a777-967c-a57103994e1d@gmail.com>
         <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com, pabeni@redhat.com,
        willemb@google.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36826 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdHZFUq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 01:20:46 -0400
Received: by mail-pg0-f45.google.com with SMTP id r133so8169849pgr.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 22:20:46 -0700 (PDT)
In-Reply-To: <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 18:52 -0700, Eric Dumazet wrote:

> I guess we should an SNMP counter for packets dropped in neigh queues.

Info is already there :

cat /proc/net/stat/arp_cache
