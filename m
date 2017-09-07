From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: ipset losing entries on its own
Date: Thu, 7 Sep 2017 10:47:20 +0530
Message-ID: <CAA5aLPiENU+k0=tH1jPvSdmdEcMDFfgk0FQcHxWvz8tYCaNZzg@mail.gmail.com>
References: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
 <c7abf292ac5e6202993a10a66537141e@nuclearcat.com> <CAA5aLPgUcrUpqJJ8stu1543LBy0qekgQDuJyokqLPP0TirySgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33126 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753671AbdIGFRV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 01:17:21 -0400
In-Reply-To: <CAA5aLPgUcrUpqJJ8stu1543LBy0qekgQDuJyokqLPP0TirySgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What I observed is rehashing of set is not happening.

When I add multiple IPs to the ipset manually on ipset v6.32,
rehashing is not happening and my hashsize remains same as 1024

but when I add to ipset 4.5 (pretty old, I know!), rehashing is
happening and my hashsize changes from 1024 to 1536 to 2304 to 3456!
