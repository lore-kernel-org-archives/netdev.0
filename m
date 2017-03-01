From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Wed, 01 Mar 2017 09:32:39 -0800
Message-ID: <1488389559.9415.300.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UeSpxzgePoidJumQFvM5a2mOC5+rL8gCHqvX-HBvrn74A@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DCFE727EB@AcuExch.aculab.com>
         <CAKgT0Ud7dPwyj4Ze4HRJOXTpywBF8VZrELQAay-Sxsv+7+Pozw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35430 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751565AbdCARdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:33:01 -0500
Received: by mail-pg0-f66.google.com with SMTP id 1so6509275pgz.2
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 09:32:40 -0800 (PST)
In-Reply-To: <CAKgT0Ud7dPwyj4Ze4HRJOXTpywBF8VZrELQAay-Sxsv+7+Pozw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-01 at 08:14 -0800, Alexander Duyck wrote:

> What build flags are you using?  With -Os or -O2 I have seen it
> convert the /b * c into a single shift.
> 


Because b & c are unsigned in our case.

I presume David tried signed integers, this is why gcc does that.
