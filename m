From: Donald Becker <becker@scyld.com>
Subject: Re: Network oops
Date: Tue, 11 Jun 2002 21:35:23 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae68ng$ofp$2@main.gmane.org>
References: <OFFF217683.8ACE4FCF-ON85256BD4.004D1229@raleigh.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <linux-net@vger.kernel.org>, <linux-net-owner@vger.kernel.org>,
   <netdev@oss.sgi.com>, <pekkas@netcore.fi>
Return-path: <owner-netdev@oss.sgi.com>
To: Mala Anand <manand@us.ibm.com>
In-Reply-To: <OFFF217683.8ACE4FCF-ON85256BD4.004D1229@raleigh.ibm.com>
List-Id: netdev.vger.kernel.org

On Mon, 10 Jun 2002, Mala Anand wrote:

>  I have see this problem with this NIC.  You need to increase
> the number of buffers in the RX and TX ring in eepro100.c file.
> Right now it is set to 32, change it to 256 or 128 this error
> will go away.

Changing the Tx queue size or number of Rx skbuffs waiting to be filled
will not fix a problem.  It might mask some problem e.g. a temporary
shortage of skbuffs, but it doesn't fix anything.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
