From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] vlan - device refcount bug.
Date: Mon, 9 Aug 2004 16:49:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809164920.54f68bc2.davem@redhat.com>
References: <20040803131425.503f8f45@dell_ss3.pdx.osdl.net>
	<410FF740.5060903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <410FF740.5060903@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Aug 2004 13:36:16 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Stephen Hemminger wrote:
> > If you rmmod a network device that is in a vlan, the system hangs waiting
> > for the refcount to go to zero, because it is -1.  The problem is that the
> > vlan notifier does an extra dev_put in NETDEV_UNREGISTER case of notifier.
> 
> Good catch.  It would seem to me that it would be good to have a
> BUG() or similar to catch any instance of the reference count going
> negative.

I'd likely accept such a patch. :-)
