From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] [RTNETLINK] Fix RTM_MAX to represent the maximum valid message type
Date: Wed, 4 May 2005 00:20:03 +0200
Message-ID: <20050503222003.GQ577@postel.suug.ch>
References: <20050430195058.GC577@postel.suug.ch> <20050503142740.345925ea.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050503142740.345925ea.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050503142740.345925ea.davem@davemloft.net> 2005-05-03 14:27
> Excellent observation.  The fact that we encode the "modifies state"
> in the low bits of the RTM_* numbers has always been a source of
> obscure bugs and hard to track down errors.
> 
> Patch applied, thanks.

Do you want 2.4 backports for all patches or just the xfrm
off-by-one fix?
