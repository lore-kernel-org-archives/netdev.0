From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [NEIGH]: Provide number of probes to userspace
Date: Fri, 04 Mar 2005 12:32:28 +0900 (JST)
Message-ID: <20050304.123228.08284664.yoshfuji@linux-ipv6.org>
References: <20050304023121.GC31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: tgraf@suug.ch, davem@davemloft.net
In-Reply-To: <20050304023121.GC31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050304023121.GC31837@postel.suug.ch> (at Fri, 4 Mar 2005 03:31:21 +0100), Thomas Graf <tgraf@suug.ch> says:

> Provides number of probes done so far to userspace, quite useful for debugging.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

It might be useful to provide probe count per state; e.g.
  in INCOMPLETE: probes
  in PROBLE    : probes - (ucast_probes + app_probes)
However, we can do this in userspace.

Not strong opinion.

--yoshfuji
