From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 00/10] net: l3mdev: Support for sockets bound
 to enslaved device
Date: Tue, 1 Aug 2017 14:15:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00482E4@AcuExch.aculab.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'David Ahern' <dsahern@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:52098 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbdHAOPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 10:15:11 -0400
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern
> Sent: 01 August 2017 04:13
...
> Existing code for socket lookups already pass in 6+ arguments. Rather
> than add another for the enslaved device index, the existing lookups
> are converted to use a new sk_lookup struct. From there, the enslaved
> device index becomes another element of the struct.
> 
> Patch 1 introduces sk_lookup struct and helper.

I guess that socket lookup happens quite often!
Passing the lookup parameters in a structure might have a
measurable negative effect on performance - especially if the
structure isn't passed through to other functions.

Have you made any performance mearurements?

	David
