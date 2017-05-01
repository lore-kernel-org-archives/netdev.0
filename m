From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/4] xdp: propagate extended ack to XDP setup
Date: Mon, 01 May 2017 12:46:31 +0200
Message-ID: <59071207.7010401@iogearbox.net>
References: <20170501044648.13022-1-jakub.kicinski@netronome.com> <20170501044648.13022-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
        bblanco@gmail.com, john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com, brouer@redhat.com, jhs@mojatatu.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41136 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S378806AbdEAKqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 06:46:35 -0400
In-Reply-To: <20170501044648.13022-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2017 06:46 AM, Jakub Kicinski wrote:
> Drivers usually have a number of restrictions for running XDP
> - most common being buffer sizes, LRO and number of rings.
> Even though some drivers try to be helpful and print error
> messages experience shows that users don't often consult
> kernel logs on netlink errors.  Try to use the new extended
> ack mechanism to carry the message back to user space.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
