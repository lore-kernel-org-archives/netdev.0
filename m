From: Solar Designer <solar@openwall.com>
Subject: Re: [PATCH net] ping: implement proper locking
Date: Sat, 25 Mar 2017 01:30:29 +0100
Message-ID: <20170325003028.GA31430@openwall.com>
References: <1490398185.24891.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mother.openwall.net ([195.42.179.200]:60434 "HELO
        mother.openwall.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S934689AbdCYAah (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 20:30:37 -0400
Content-Disposition: inline
In-Reply-To: <1490398185.24891.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 04:29:45PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> We got a report of yet another bug in ping
> 
> http://www.openwall.com/lists/oss-security/2017/03/24/6
> 
> ->disconnect() is not called with socket lock held.
> 
> Fix this by acquiring ping rwlock earlier.
> 
> Thanks to Alexander and Andrey for letting us know of this problem.
> 
> Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
> Reported-by: Solar Designer <solar@openwall.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

We should credit the original reporter, who most likely found this by
fuzzing.  It's danieljiang0415 on GitHub and Twitter.  Unfortunately, I
don't know their e-mail address.  I'll try asking.

Alexander
