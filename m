From: Willy Tarreau <w@w.ods.org>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Thu, 22 Apr 2004 15:17:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040422131704.GA6839@alpha.home.local>
References: <XFMail.20040422102359.pochini@shiny.it> <Pine.LNX.4.53.0404220734330.8039@chaos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Richard B. Johnson" <root@chaos.analogic.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.53.0404220734330.8039@chaos>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 22, 2004 at 07:35:54AM -0400, Richard B. Johnson wrote:
 
> Has anybody checked to see what Linux does if it receives a
> RST to the broadcast address? It would be a shame if all
> connections were dropped!

I don't see how this would be possible : a TCP packet is matched *only* if
it refers to a valid session. If you have no session established from/to the
broadcast address, there's no possibility that an RST targetted at this address
terminates anything, even if the ports are OK.

Cheers,
Willy
