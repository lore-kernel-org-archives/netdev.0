From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 16:34:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801163415.1c3fd6fb.davem@redhat.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
	<20030801154021.GA7696@gtf.org>
	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
	<20030801162536.GA18574@gtf.org>
	<20030801132037.3f3542ae.davem@redhat.com>
	<3F2AE91D.5090705@pobox.com>
	<3F2AEB33.9050506@pobox.com>
	<20030801153439.4a324c36.davem@redhat.com>
	<3F2AF32F.7090201@pobox.com>
	<20030801160857.32ebbf22.davem@redhat.com>
	<3F2AF938.7050608@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2AF938.7050608@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Aug 2003 19:35:20 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Inside an area allocated by the kcompat lib.  SET_ETHTOOL_OPS takes 
> 'struct net_device *' and 'struct ethtool_ops *' arguments, so it simply 
> needs to create a lookup list/table somewhere.

Ok ok ok, we're converging :-)

Please just comment on my other email suggesting a way
to do away with DO_ETHTOOL_OPS.

I'm OK with a SET_ETHTOOL_OPS() macro.
