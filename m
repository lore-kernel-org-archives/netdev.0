From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] netdev_ops
Date: Wed, 9 Jul 2003 18:25:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709172525.GZ1939@parcelfarce.linux.theplanet.co.uk>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk> <3F0C4CA8.7090502@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com,
   "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3F0C4CA8.7090502@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 09, 2003 at 10:11:04AM -0700, Ben Greear wrote:
> Considering any number of things may change in the future, what do
> you think of adding a global 'nettool-version' method.  That could
> allow user-space code to take appropriate action if something ever
> changes in a non-compatible way....

This patch makes only user-invisible changes.  I'm trying to establish a
base for further cleanups (eg, acme wants to look at unifying the wireless
ops and the existing net_device function pointers into netdev_ops).
I don't really have a position on adding a nettool-version ioctl or
whatever, but I'm not sure it would make sense to have that as a netdev
method.

> Also, for the strings (labels) passed back to user space, is there any
> documentation for suggested values for these strings?  Even though we
> can't be completely type-safe, if there were suggested values in
> a comment in the code, it could help a great deal for any code trying to
> parse them for multiple different drivers/nics.

I didn't see any documentation; I just read the code.  The only drivers
I noticed supporting the GSTRINGS subcommand are 8139cp, 8139too, e100
and e1000.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
