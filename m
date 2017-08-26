From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP sockets oddities
Date: Fri, 25 Aug 2017 20:40:44 -0700
Message-ID: <1503718844.11498.19.camel@edumazet-glaptop3.roam.corp.google.com>
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
         <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com, willemb@google.com,
        davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:38222 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752938AbdHZDkq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 23:40:46 -0400
Received: by mail-pg0-f48.google.com with SMTP id b8so7655500pgn.5
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 20:40:46 -0700 (PDT)
In-Reply-To: <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 20:25 -0700, Florian Fainelli wrote:

> It would. Since the call trace involves udp_send_skb() how come we are
> not returning an error to write(2)? are there other code paths where the
> neighbor code can do drops like these?

Are you suggesting write(2) should block until ARP resolution is
done ? :)

What about non blocking writes ?

Honestly UDP is not a protocol for which we must absolutely be sure
packets are sent or not.
