From: "Bryan O'Sullivan" <bos@keyresearch.com>
Subject: Re: [ANNOUNCE] netplug, a daemon that handles network cables
	getting plugged in and out
Date: 28 Aug 2003 15:49:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062110960.12285.94.camel@serpentine.internal.keyresearch.com>
References: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com>
	 <20030828215417.GA22215@werewolf.able.es> <3F4E8373.1040204@pobox.com>
	 <20030828224553.GC23528@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <20030828224553.GC23528@werewolf.able.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-08-28 at 15:45, J.A. Magallon wrote:

> That would be very nice, but there is still a problem.
> Does netlink solve the fact that there are cards (at least in 2.4)
> that do not support any detection method:

netlink doesn't work through the ioctl interface at all.  If a card is
capable of reporting that its flags include IFF_UP or IFF_RUNNING via
the netlink interface, then netplug will work.

	<b
