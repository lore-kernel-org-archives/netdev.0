From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Fri, 16 Sep 2016 22:52:52 +0300
Message-ID: <20160916195252.GC18116@uranus.lan>
References: <20160915202219.GB1867@uranus.lan>
 <f482796f-185e-a3b7-248c-20f1f39cb459@cumulusnetworks.com>
 <20160915210126.GC1867@uranus.lan>
 <1473979691.22679.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <999f0ddb-82e4-ea07-b52a-59d08bc7816d@cumulusnetworks.com>
 <20160916070623.GD1867@uranus.lan>
 <20160916190000.GA18116@uranus.lan>
 <59e12627-7043-fd20-0d68-899ab43b0e71@cumulusnetworks.com>
 <20160916193927.GB18116@uranus.lan>
 <d943c6b7-0f06-3823-58d2-6f79f17c3d59@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:36320 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753480AbcIPTw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:52:56 -0400
Content-Disposition: inline
In-Reply-To: <d943c6b7-0f06-3823-58d2-6f79f17c3d59@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 01:47:57PM -0600, David Ahern wrote:
> >>
> >> I'm guessing you passed IPPROTO_RAW (255) as the protocol to socket(). If you pass something
> >> else (IPPROTO_ICMP for example) it won't work.
> > 
> > True. To support IPPROTO_ICMP it need enhancement. I thought start with
> > plain _RAW first and then extend to support _ICMP.
> 
> I thought raw in this case was SOCK_RAW as in the socket type.
> 
> Since the display is showing sockets in addition to IPPROTO_RAW:
> 
> $ ss -A raw
> State      Recv-Q Send-Q        Local Address:Port                         Peer Address:Port
> UNCONN     0      0                    *%eth0:icmp                                    *:*
> 
> It is going to be confusing if only ipproto-255 sockets can be killed.

OK, gimme some time to implement it. Hopefully on the weekend or monday.
Thanks a huge for feedback!
