From: Andi Kleen <ak@muc.de>
Subject: Re: Intel and TOE in the news
Date: 22 Feb 2005 19:07:11 +0100
Message-ID: <20050222180711.GA84438@muc.de>
References: <1109005880.1076.77.camel@jzny.localdomain> <200502211803.j1LI3cDD009072@guinness.s2io.com> <20050222100227.7ea76f2c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leonid Grossman <leonid.grossman@neterion.com>, hadi@cyberus.ca,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
Date: Tue, 22 Feb 2005 19:07:11 +0100
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050222100227.7ea76f2c@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Be careful, this may have the same problems that original TSO code did.
> Make sure and force the PUSH flag on these jumbo receives or the TCP
> "every other segment" ACK logic will be busted.  There are other parts of TCP

> that depend on packet count as well and this inverse TSO logic will break them.

Linux TCP RX path didn't care about PSH last time I checked. It should
make no difference how PSH is set on RX or if it is set at all. At least
unless Leonid wants to run his driver on Darwin too, but that would be 
someone else's problem.

-Andi
