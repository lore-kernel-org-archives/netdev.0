From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [RTNETLINK] Fix RTM_MAX to represent the maximum
 valid message type
Date: Tue, 3 May 2005 15:27:04 -0700
Message-ID: <20050503152704.4c6744d6.davem@davemloft.net>
References: <20050430195058.GC577@postel.suug.ch>
	<20050503142740.345925ea.davem@davemloft.net>
	<20050503222003.GQ577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050503222003.GQ577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 May 2005 00:20:03 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * David S. Miller <20050503142740.345925ea.davem@davemloft.net> 2005-05-03 14:27
> > Excellent observation.  The fact that we encode the "modifies state"
> > in the low bits of the RTM_* numbers has always been a source of
> > obscure bugs and hard to track down errors.
> > 
> > Patch applied, thanks.
> 
> Do you want 2.4 backports for all patches or just the xfrm
> off-by-one fix?

Congratulations if you can find xfrm in the vanilla
2.4.x tree :-)
