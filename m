From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: net-next closing, README
Date: Wed, 7 Dec 2016 19:20:18 -0800
Message-ID: <20161207192018.4b1d1b2a@xeon-e3>
References: <20161207.162845.1424733568267357691.davem@davemloft.net>
        <20161207191345.6e765651@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35348 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932774AbcLHDU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 22:20:26 -0500
Received: by mail-pg0-f41.google.com with SMTP id p66so168960186pga.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 19:20:26 -0800 (PST)
In-Reply-To: <20161207191345.6e765651@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Dec 2016 19:13:45 -0800
Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Wed, 07 Dec 2016 16:28:45 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
> > The merge window is about to open soon, and next week I will be
> > having sporadic internet access while travelling around, therefore
> > I am closing net-next up tonight.
> > 
> > Therefore, please do not submit any new features or cleanups for
> > net-next.  Bug fixes for problems introduced in net-next are fine,
> > however.
> > 
> > Thank you.  
> 
> I have a couple of patches that I would like to get into net-next, but
> it is not critical. They replace the hardcoded workarounds with code
> that negotiates values with the host. Would these be acceptable?
> Sorry for the delay but needed to test on oldest supported version
> to ensure negotiation worked.

Never mind, although the changes work on older versions of Windows Server,
the performance would be worse.  Basically old servers don't do UDP checksum
offload but still are capable of handling TCP.  Let me work up a better
solution that handles both cases.
