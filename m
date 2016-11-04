From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: Coding Style: Reverse XMAS tree declarations ? (was Re: [PATCH
 net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet)
Date: Fri, 4 Nov 2016 12:01:17 +0100
Message-ID: <581C6A7D.8030704@marvell.com>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
 <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
 <20161103.155816.642712588084106823.davem@davemloft.net>
 <1478242438.1924.31.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
        <linux-kernel@vger.kernel.org>, <oss@buserror.net>,
        <ppc@mindchasers.com>, <pebolle@tiscali.nl>,
        <joakim.tjernlund@transmode.se>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        <madalin.bucur@nxp.com>, Andrew Morton <akpm@linux-foundation.org>,
        "Jonathan Corbet" <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478242438.1924.31.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 04.11.2016 07:53, Joe Perches wrote:
>
> CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
> #446: FILE: drivers/net/ethernet/ethoc.c:446:
> +			int size = bd.stat >> 16;
> +			struct sk_buff *skb;
>

should not this case be valid? Optically the longer line is already before the shorter.
I think that the whole point in using this reverse xmas tree ordering is to have
the code optically tidied up and not to enforce ordering between variable name lengths.


Regards,
Lino
