From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tulip, kernel 2.4.26-rc2, 2nd try
Date: Fri, 09 Apr 2004 15:33:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4076FA7F.7020801@pobox.com>
References: <Pine.LNX.4.43.0404091519200.19041-100000@skyhawk.ecc.engr.uky.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tulip-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Timothy I Mattox <tmattox@engr.uky.edu>
In-Reply-To: <Pine.LNX.4.43.0404091519200.19041-100000@skyhawk.ecc.engr.uky.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Timothy I Mattox wrote:
> Resubmitting ADMtek Comet MII support patch...
> 
> Here is a patch for the tulip driver found in kernel 2.4.26-rc2
> This adds MII functionality to the ADMtek Comet flavor of the tulip,
> specifically, the ability to detect and report the link status with MII.
> This is critical for use with newer channel bonding drivers.
> 
> I've tested on several Linksys LNE100TX v4.1 PCI cards, as well as on
> an HP Pavilion N5475 laptop with a built-in NIC that is detected as
> this same model of chip.  I have over 750 of this model tulip card in
> use in various beowulf clusters.
> 
> This patch was modeled after Donald Becker's tulip.c:v0.98 1/8/2004, but
> the specific bits from his driver have been there for about two years.
> (See: http://sourceforge.net/mailarchive/message.php?msg_id=1841280)


Looks OK, but can you test without netif_carrier_xxx commented out?

I would prefer to leave those active.

	Jeff
