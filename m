From: "Jay Vosburgh" <fubar@us.ibm.com>
Subject: Re: PATCH Re: [Bonding-devel] Re: Bonding driver unreliable under high
 CPUload
Date: Wed, 18 Sep 2002 17:56:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF516AEB0B.459BB3DC-ON88256C39.0004B863@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@digeo.com>,
   "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



      No, it doesn't.  This is a mere band aid until somebody can get time
to do it right.  It's "less bad."

      -J


Jeff Garzik <jgarzik@mandrakesoft.com> on 09/18/2002 05:48:24 PM

To:    Jay Vosburgh/Beaverton/IBM@IBMUS
cc:    Andrew Morton <akpm@digeo.com>, "Cureington, Tony"
       <tony.cureington@hp.com>, Pascal Brisset
       <pascal.brisset-ml@wanadoo.fr>, bonding-devel@lists.sourceforge.net,
       netdev@oss.sgi.com
Subject:    Re: PATCH Re: [Bonding-devel] Re: Bonding driver unreliable
       under high CPUload



Jay Vosburgh wrote:
>
>       Ok, here is a patch for bonding against 2.4.20-pre7.  This gets rid
> of the MII_whatever macros, wraps ioctl() to make it less bad, and
replaces
> a couple of magic numbers with friendly labels.
>
>       Comments?


The patch looks ok but doesn't address the core problem that the link
state is checked in interrupt context.

 Jeff
