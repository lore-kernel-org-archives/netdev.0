From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Mon, 18 Aug 2003 02:21:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818022131.311583f6.davem@redhat.com>
References: <20030817221804.27e2f07d.davem@redhat.com>
	<Pine.LNX.4.44.0308180959150.3006-100000@notebook.home.mdiehl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, shemminger@osdl.org, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Diehl <lists@mdiehl.de>
In-Reply-To: <Pine.LNX.4.44.0308180959150.3006-100000@notebook.home.mdiehl.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 10:48:28 +0200 (CEST)
Martin Diehl <lists@mdiehl.de> wrote:

> So the question arises what to do if 
> some stack (say irda ;-) *wants* to lock the driver providing the netdev 
> while registered?

You can't, you have to interlock with netdevice removal
and also capture NETDEV_GOING_DOWN events to properly
handle when netdevices disappear.
