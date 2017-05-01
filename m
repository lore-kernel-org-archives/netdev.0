From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] [PATCH net-next 0/4] xdp: use netlink extended ACK
 reporting
Date: Mon, 1 May 2017 12:32:00 +0200
Message-ID: <20170501103158.GB24399@vergenet.net>
References: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        johannes@sipsolutions.net, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        bblanco@gmail.com, john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com, brouer@redhat.com, jhs@mojatatu.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37680 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1952236AbdEAKcF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 06:32:05 -0400
Received: by mail-wm0-f45.google.com with SMTP id m123so94425425wma.0
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 03:32:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 30, 2017 at 09:46:44PM -0700, Jakub Kicinski wrote:
> Hi!
> 
> This series is an attempt to make XDP more user friendly by 
> enabling exploiting the recently added netlink extended ACK 
> reporting to carry messages to user space.
> 
> David Ahern's iproute2 ext ack patches for ip link are sufficient
> to show the errors like this:
> 
> # ip link set dev p4p1 xdp obj ipip_prepend.o sec ".text"
> Error: nfp: MTU too large w/ XDP enabled
> 
> Where the message is coming directly from the driver.  There could
> still be a bit of a leap for a complete novice from the message 
> above to the right settings, but it's a big improvement over the
> standard "Invalid argument" message.
> 
> v1/non-rfc:
>  - add a separate macro in patch 1;
>  - add KBUILD_MODNAME as part of the message (Daniel);
>  - don't print the error to logs in patch 1.
> 
> Jakub Kicinski (4):
>   netlink: add NULL-friendly helper for setting extended ACK message
>   xdp: propagate extended ack to XDP setup
>   nfp: make use of extended ack message reporting
>   virtio_net: make use of extended ack message reporting

Reviewed-by: Simon Horman <simon.horman@netronome.com>
