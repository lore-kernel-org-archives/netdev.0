From: Laurent Deniel <laurent.deniel@free.fr>
Subject: Re: [Bonding-devel] [bonding][3/3] Synchronizing 2.4-2.6
Date: Thu, 28 Aug 2003 19:17:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4E391F.6030403@free.fr>
References: <200308272008.20139.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Shmulik Hen wrote:
>
> patch 7 - eliminate the multicast_more module param and use the 
> 	  USES_PRIMARY macro instead.

Do you know that this breaks upward compatibility ? i.e. this now
assumes that for instance in active backup mode, only the active
slave registers the multicast addresses (i.e. multicast_mode = 1)
while the default from the very beginning was all NIC (multicast_mode = 0).
And this removes the possiblity of disabling multicast stuff.
But if everyone is OK ... (I'd be since I currently only use
multicast_mode = 1 ;-)

Laurent
