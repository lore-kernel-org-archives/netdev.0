From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: fix *_DIAG_MAX constants
Date: Thu, 21 Mar 2013 14:42:18 +0000
Message-ID: <20130321144218.GF9046@casper.infradead.org>
References: <1363875500-14574-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <edumazet@google.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Howells <dhowells@redhat.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363875500-14574-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/13 at 06:18pm, Andrey Vagin wrote:
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

Acked-by: Thomas Graf <tgraf@suug.ch>
