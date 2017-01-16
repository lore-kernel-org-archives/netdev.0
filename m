From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 3/9] net/mlx4_core: Set EQ affinity hint to local
 NUMA CPUs
Date: Mon, 16 Jan 2017 23:59:47 +0200
Message-ID: <CAJ3xEMjGv8xm7vOgASd0CvpS9uQFLv8tT_n7aqsuoB7eTUAZUg@mail.gmail.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
 <1484587805-12666-4-git-send-email-tariqt@mellanox.com> <CAJ3xEMiGQHV1Qc0aW43SJaNO7X5TRLdYRaZgEiA6099vbBAAXw@mail.gmail.com>
 <VI1PR0501MB2429F11A34431293F2D0C327C47D0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Daniel Jurgens <danielj@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:36457 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdAPV7s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 16:59:48 -0500
Received: by mail-ua0-f195.google.com with SMTP id f2so10849614uaf.3
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 13:59:48 -0800 (PST)
In-Reply-To: <VI1PR0501MB2429F11A34431293F2D0C327C47D0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 11:54 PM, Daniel Jurgens <danielj@mellanox.com> wrote:
> On 1/16/2017 3:44 PM, Or Gerlitz wrote:
>> On Mon, Jan 16, 2017 at 7:29 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
>>> From: Daniel Jurgens <danielj@mellanox.com>
>>>
>>> Use CPUs on the close NUMA when setting the EQ affinity hints.
>> Dan, are we sure there are no down-sides for always doing this? this
>> code is probably there for many years and we're introducing here new
>> behaviour to potentially to many Ms installs when they get distro
>> update that includes this patch.


> I don't see a downside, this just favors using the node local CPUs before others.

OK, so this just favors before others and not limits (not in front of
the code now)? would be good to improve the change log and make this
clear.

> I don't understand your 2nd sentence there.  "Ms installs"?

Millions of installs that run Linux driver.
