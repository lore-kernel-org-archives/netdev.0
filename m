From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: PATCH Re: [Bonding-devel] Re: Bonding driver unreliable under
 high CPUload
Date: Wed, 18 Sep 2002 20:48:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D891ED8.3080803@mandrakesoft.com>
References: <OF8AA69633.CB78BDA6-ON88256C39.0001934D@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>,
   "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 
>       Ok, here is a patch for bonding against 2.4.20-pre7.  This gets rid
> of the MII_whatever macros, wraps ioctl() to make it less bad, and replaces
> a couple of magic numbers with friendly labels.
> 
>       Comments?


The patch looks ok but doesn't address the core problem that the link 
state is checked in interrupt context.

	Jeff
