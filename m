From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP sockets oddities
Date: Fri, 25 Aug 2017 16:57:20 -0700
Message-ID: <1503705440.11498.9.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3fed7679-0e19-8a0a-eee6-11baa5654fac@gmail.com>
         <1503527210.2499.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <9a9c1c94-4902-2ec9-d216-3f5cfb3044af@gmail.com>
         <1503529476.2499.65.camel@edumazet-glaptop3.roam.corp.google.com>
         <6c88e440-3f36-858d-1a08-bd32a2c66f4e@gmail.com>
         <1503535426.2499.66.camel@edumazet-glaptop3.roam.corp.google.com>
         <4adb4b66-590c-c55a-44aa-27dd409ce14f@gmail.com>
         <3c44d27e-27d9-e9c4-04b3-17c0366e60d9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com, pabeni@redhat.com,
        willemb@google.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32856 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755268AbdHYX5W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 19:57:22 -0400
Received: by mail-pg0-f68.google.com with SMTP id q16so1740111pgc.0
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 16:57:22 -0700 (PDT)
In-Reply-To: <3c44d27e-27d9-e9c4-04b3-17c0366e60d9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 16:18 -0700, Florian Fainelli wrote:

> Eric, are there areas of the stack where we are allowed to drop packets,
> not propagate that back to write(2) and also not increment any counter
> either, or maybe I am not looking where I should...

What happens if you increase these sysctls ?

grep .  `find /proc/sys|grep unres_qlen`


unres_qlen_bytes -> 2000000
unres_qlen -> 10000
