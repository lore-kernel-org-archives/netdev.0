From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 2 Jul 2012 01:14:48 -0700
Message-ID: <CAG4TOxNyxP8FpzNdMZR3WMvFCQtEx_r3oLh6s7sZOcBnqN=6tA@mail.gmail.com>
References: <1341135823-29039-7-git-send-email-ogerlitz@mellanox.com>
 <20120701.033055.489908836962064737.davem@davemloft.net> <4FF042B5.1000303@mellanox.com>
 <20120701.144252.792146486861614931.davem@davemloft.net> <4FF153F0.8080707@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, yevgenyp@mellanox.com,
	oren@mellanox.com, netdev@vger.kernel.org, hadarh@mellanox.co.il
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:56306 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161Ab2GBIPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 04:15:09 -0400
Received: by obbuo13 with SMTP id uo13so7872371obb.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 01:15:08 -0700 (PDT)
In-Reply-To: <4FF153F0.8080707@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 2, 2012 at 12:55 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> On 7/2/2012 12:42 AM, David Miller wrote:
>> [...] Module parameters stink because every driver is going to provide the
>> knob differently, with a different name, and different semantics. This
>> creates a terrible user experience, and I will not allow it.
>
> OK, so if looking on what we are left with on the table, seems that sysfs
> entry on the mlx4_core
> level (as we do for the port link type {IB, Eth} or IB port MTU) could be
> fine here, Roland, agree?

What was wrong with Dave's initial suggestion of ethtool?  All the
other steering stuff is configured that way, why not this hash?

 - R.
