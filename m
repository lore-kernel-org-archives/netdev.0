From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] xdp: use netlink extended ACK reporting
Date: Mon, 01 May 2017 10:36:06 -0400 (EDT)
Message-ID: <20170501.103606.1985325558874702325.davem@davemloft.net>
References: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com, brouer@redhat.com, jhs@mojatatu.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752222AbdEAOgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 10:36:08 -0400
In-Reply-To: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Sun, 30 Apr 2017 21:46:44 -0700

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

Series applied.
