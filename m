From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [PATCH 2.4] e1000 0/7 driver update
Date: Thu, 27 May 2004 10:52:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E0135F762@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, "Netdev" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff:

I will apply the process change to all future submittals.

I agree with your decision not to apply patch 5 "enable TSO".

Thanks,
ganesh 
 
-------------------------------------------------
Ganesh Venkatesan
Network/Storage Division, Hillsboro, OR

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Thursday, May 27, 2004 10:48 AM
To: Venkatesan, Ganesh; Netdev
Subject: Re: [PATCH 2.4] e1000 0/7 driver update

ganesh.venkatesan@intel.com wrote:
> Jeff:
> 
> Patches against 2.4 tot for the latest version of e1000 (5.2.52). I 
> verified that these patches apply*, the kernel builds fine and the
driver 
> works as expected. Please apply these patches to the upstream kernel.

Two patch submission process changes:

1) include the "1/7" number _inside_ the "[PATCH ... 2.4]" brackets.

2) please CC netdev@oss.sgi.com on patches.  This allows for greater 
peer review.


> * - p6/p7 apply with a -/+1 line offset. But this does not affect 
> anything.
> 
> p1.diff - clear auto-mdix mode when the link is forced to 10/100 mbps 
> speeds on certain PHYs
> p2.diff - workaround for link LED staying ON even when there is no
link
> p3.diff - fix to determine link status correctly while using
fiber/serdes 
> interface
> p4.diff - rewrite logic to estimate # of tx descriptors required for a

> given packet, shrink the span for which tx_lock is held
> p5.diff - enable TSO
> p6.diff - ethtool_ops support
> p7.diff - enable error logging

I applied all patches to 2.4 and 2.6 EXCEPT patch #5 "enable TSO".

Judging from your own comments, I am not confident that turning it on is

productive, with the lockups still occurring.

	Jeff
