From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,pktgen] account for preamble and inter-packet gap
Date: Wed, 1 Dec 2004 22:59:23 +0100
Message-ID: <20041201215923.GH14470@xi.wantstofly.org>
References: <20041128213251.GA9330@xi.wantstofly.org> <16811.19277.594137.939120@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16811.19277.594137.939120@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2004 at 05:16:13PM +0100, Robert Olsson wrote:

>  I've heard some boxes that didn't do the ipg correctly. Don't know what NIC 
>  this was. We can only estimate stats at the point where we are delivering 
>  packets. Other devices has "true" L2 stats.

Just found out the other day that via-rhine appears to do this.


>  OK. Adding FCS yes kinda compromise and maybe was wrong in this aspect.

Let's remove it then?


>  The only solution I can think of is of having a selectable option in 
>  the config for output stats. To support different L2 layers and with  
>  warning if we are "predicting" L2 statistics. Feel free to extend your
>  patch.

At that point it might be easier to just do it in userspace, no?


--L
