From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Bug 194723] connect() to localhost stalls after 4.9 -> 4.10
 upgrade
Date: Thu, 16 Mar 2017 09:27:17 -0700
Message-ID: <20170316092717.30b605aa@xeon-e3>
References: <20170315133619.64a31120@xeon-e3>
        <1489614034.28631.162.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170315.153017.1728029219325534654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35659 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752181AbdCPQ10 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 12:27:26 -0400
Received: by mail-pf0-f169.google.com with SMTP id x63so21245275pfx.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 09:27:25 -0700 (PDT)
In-Reply-To: <20170315.153017.1728029219325534654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Mar 2017 15:30:17 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 15 Mar 2017 14:40:34 -0700
> 
> > Finally time to get rid of buggy tw_recycle, that apparently some
> > distros set to one.  
> 
> It's not buggy, it's just not designed in a way that it can work in
> the presence of NAT.
> 
> So yes, indeed, NO DISTRO SHOULD CHANGE THE VALUE TO "1" by default.
> 
> Is CentOS the only culprit?
> 
> But removing it is unnecessary, people who know what they are doing
> can legitimately enable it if they know that there is no NAT going
> on in their paths.

The bug was reported first on CentOs but the bugzilla entry mentions
the same problem exists on Arch Linux. Ubuntu (and Debian) do not have
the problem. RHEL 7 also ok.

https://bugzilla.kernel.org/show_bug.cgi?id=194723
