From: "David S. Miller" <davem@redhat.com>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 10:30:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.103030.15245573.davem@redhat.com>
References: <20030610171617.GC1959@gtf.org>
	<20030610.101452.35033262.davem@redhat.com>
	<20030610172556.GD1959@gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, bogdan.costescu@iwr.uni-heidelberg.de, hadi@shell.cyberus.ca,
   ralph+d@istop.com, xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <20030610172556.GD1959@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Tue, 10 Jun 2003 13:25:56 -0400
   
   MMIO isn't as bad as PIO, and the 'runtime choice' setup implies
   slowing down the MMIO path, too.

No end user will see the change then, no distribution vendor worth
their salt will ship with MMIO enabled.

Right now we get only PIO and everybody suffers.  Runtime MMIO
selection is a net win for everyone.
