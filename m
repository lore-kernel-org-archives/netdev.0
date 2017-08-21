From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Mon, 21 Aug 2017 15:35:42 -0700
Message-ID: <20170821223540.atktdricmks26c27@ast-mbp>
References: <20170821212506.1cb0d5d6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?utf-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:38815 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbdHUWft (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 18:35:49 -0400
Content-Disposition: inline
In-Reply-To: <20170821212506.1cb0d5d6@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 09:25:06PM +0200, Jesper Dangaard Brouer wrote:
> 
> Third gotcha(3): You got this far, loaded xdp on both interfaces, and
> notice now that (with default setup) you can RX with 14Mpps but only
> TX with 6.9Mpps (and might have 5% idle cycles).  I debugged this via
> perf tracepoint event xdp:xdp_redirect, and found this was due to
> overrunning the xdp TX ring-queue size.

we should probably fix this somehow.
Once tx-ing netdev added to devmap we can enable xdp on it automatically?
