From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: this patch adds json support
 for bridge mdb show
Date: Tue, 18 Jul 2017 17:33:51 -0700
Message-ID: <20170718173351.55cb566a@xeon-e3>
References: <1499466256-13808-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikhil@cumulusnetworks.com,
        nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33550 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdGSAdy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 20:33:54 -0400
Received: by mail-pg0-f51.google.com with SMTP id k14so21322978pgr.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 17:33:53 -0700 (PDT)
In-Reply-To: <1499466256-13808-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Jul 2017 15:24:16 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Nikhil Gajendrakumar <nikhil@cumulusnetworks.com>
> 
> This patch adds json output to bridge mdb show
> 
> Normal Output:
> $ bridge -d -s mdb show
> dev br0 port swp3 grp 239.0.0.1 temp  vid 128 172.26
> dev br0 port swp3 grp 239.0.0.1 temp  vid 64 172.26
> dev br0 port swp2 grp 239.0.0.2 temp  vid 1024 172.26
> dev br0 port swp2 grp 239.0.0.2 temp  vid 256 172.26
> dev br0 port swp2 grp 239.0.0.2 temp  vid 1 172.26
> dev br0 port swp3 grp 239.0.0.1 temp  vid 1 172.26
> router ports on br0: swp4    0.00 permanent
> router ports on br0: swp5    0.00 permanent
> 
> Json Output:
> $ bridge -d -s -j mdb show
> {
>     "mdb": [{
>             "dev": "br0",
>             "port": "swp3",
>             "grp": "239.0.0.1",
>             "state": "temp",
>             "vid": 128,
>             "timer": " 166.74"
>         },{
>             "dev": "br0",
>             "port": "swp3",
>             "grp": "239.0.0.1",
>             "state": "temp",
>             "vid": 64,
>             "timer": " 166.74"
>         },{
>             "dev": "br0",
>             "port": "swp2",
>             "grp": "239.0.0.2",
>             "state": "temp",
>             "vid": 1024,
>             "timer": " 166.74"
>         },{
>             "dev": "br0",
>             "port": "swp2",
>             "grp": "239.0.0.2",
>             "state": "temp",
>             "vid": 256,
>             "timer": " 166.74"
>         },{
>             "dev": "br0",
>             "port": "swp2",
>             "grp": "239.0.0.2",
>             "state": "temp",
>             "vid": 1,
>             "timer": " 166.74"
>         },{
>             "dev": "br0",
>             "port": "swp3",
>             "grp": "239.0.0.1",
>             "state": "temp",
>             "vid": 1,
>             "timer": " 166.74"
>         }
>     ],
>     "router": {
>         "br0": [{
>                 "port": "swp4",
>                 "timer": "   0.00",
>                 "type": "permanent"
>             },{
>                 "port": "swp5",
>                 "timer": "   0.00",
>                 "type": "permanent"
>             }
>         ]
>     }
> }
> 
> Signed-off-by: Nikhil Gajendrakumar <nikhil@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, you should also update usage message and man page.
