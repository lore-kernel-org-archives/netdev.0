From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: netlink: register netdevice before
 executing changelink
Date: Fri, 7 Apr 2017 14:44:16 -0400
Message-ID: <20170407144416.625462ec@plumbers-lap.home.lan>
References: <20170407124915.15508-1-idosch@mellanox.com>
        <20170407101055.745d95d0@plumbers-lap.home.lan>
        <3d567660-7fa5-979e-3097-89427270e554@cumulusnetworks.com>
        <20170407112206.77b515cd@plumbers-lap.home.lan>
        <23249e09-a712-920f-9a9f-850055aaf3af@cumulusnetworks.com>
        <20170407113615.15891fde@plumbers-lap.home.lan>
        <c3769204-4803-6c5f-1286-c8f1f5e045be@cumulusnetworks.com>
        <20170407133753.1602f3cd@plumbers-lap.home.lan>
        <20170407181649.GA21938@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        idosch@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, mlxsw@mellanox.com,
        peter@svinota.eu, cera@cera.cz
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:37831 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932993AbdDGSoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:44:21 -0400
Received: by mail-it0-f46.google.com with SMTP id a140so47434754ita.0
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 11:44:20 -0700 (PDT)
In-Reply-To: <20170407181649.GA21938@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Apr 2017 21:16:49 +0300
Ido Schimmel <idosch@idosch.org> wrote:

> On Fri, Apr 07, 2017 at 01:37:53PM -0400, Stephen Hemminger wrote:
> > Fix it right now. The patch you propose is too half baked.  
> 
> Given this patch needs to be back ported to three different stable
> kernels I tried to keep the amount of changes to a minimum while fixing
> the bug.
> 
> I'll work on the ndo_uninit() patch and submit it. Then people can
> decide which course of action they're more comfortable with.

I don't want enterprise distros to ship without error reporting.
At a minimum just return correct errno and leave bridge in stuck/broken state.
