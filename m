From: Stefan Rompf <srompf@isg.de>
Subject: Re: e100: "Freeing alive device f7dd8000, eth%d"
Date: Mon, 07 Apr 2003 18:49:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E91AC1B.D914760B@isg.de>
References: <Pine.LNX.4.44.0304052219240.5390-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Scott Feldman wrote:

> This should do the trick, but I'd like to get some testing on it in the QA
> lab before giving thumbs up.

[...]

> +               if(!netif_carrier_ok(bdp->device) && netif_running(bdp->device))

even though this will avoid the problem, I think it is the wrong
solution: Your code is still calling operating system functions on a
netdevice that has not been register_netdevice()d yet. This will invite
problems of all kind.

Cheers, Stefan
