From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 16:09:26 +0300
Message-ID: <20160928130926.GD1876@uranus.lan>
References: <20160928090357.GT1876@uranus.lan>
 <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
 <20160928101726.GU1876@uranus.lan>
 <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
 <20160928105147.GV1876@uranus.lan>
 <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
 <20160928112703.GW1876@uranus.lan>
 <1475067432.28155.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <1475067731.28155.92.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36260 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932172AbcI1NJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 09:09:30 -0400
Content-Disposition: inline
In-Reply-To: <1475067731.28155.92.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 06:02:11AM -0700, Eric Dumazet wrote:
> 
> This is a bit different of course, since struct tc_fq_qd_stats is only
> one way : Kernel produces the content and gives it to user space.
> 
> User space should probably not need to initialize such a structure, but
> who knows what a programmer can write ;)

It's the same issue as I have: the users may have initialized tc_fq_qd_stats for
some reson. But since nobody complained yet about such change -- it is a good
sign of catching the luck :)

You know at the moment I'm not sure how to be then -- either leave it as
uninon, either rename it (via patch on top), or even simply require the
protocol to be passed as additional data in netlink packet...
