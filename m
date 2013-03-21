From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: fix *_DIAG_MAX constants
Date: Thu, 21 Mar 2013 12:37:13 -0400 (EDT)
Message-ID: <20130321.123713.2259863785549784643.davem@davemloft.net>
References: <1363883628-7249-1-git-send-email-avagin@openvz.org>
	<1363883628-7249-2-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xemul@parallels.com, edumazet@google.com,
	paulmck@linux.vnet.ibm.com, dhowells@redhat.com
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363883628-7249-2-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Vagin <avagin@openvz.org>
Date: Thu, 21 Mar 2013 20:33:46 +0400

> Follow the common pattern and define *_DIAG_MAX like:
> 
>         [...]
>         __XXX_DIAG_MAX,
> };
> 
> Because everyone is used to do:
> 
>         struct nlattr *attrs[XXX_DIAG_MAX+1];
> 
>         nla_parse([...], XXX_DIAG_MAX, [...]
> 
> Reported-by: Thomas Graf <tgraf@suug.ch>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Cc: David Howells <dhowells@redhat.com>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied to 'net' and queued up for -stable.

Thanks.
