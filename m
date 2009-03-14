From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: iproute2 and regressing "ipv6: convert tunnels to net_device_ops"
Date: Sat, 14 Mar 2009 19:34:38 +0100
Message-ID: <200903141934.38915.rjw@sisk.pl>
References: <alpine.LSU.2.00.0903091400200.28029@fbirervta.pbzchgretzou.qr> <200903091414.15171.rjw@sisk.pl> <alpine.LSU.2.00.0903091545430.2331@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:41107 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087AbZCNSeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Mar 2009 14:34:36 -0400
In-Reply-To: <alpine.LSU.2.00.0903091545430.2331@fbirervta.pbzchgretzou.qr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 09 March 2009, Jan Engelhardt wrote:
> 
> (Cc'ed netdev ml)

Tracked as http://bugzilla.kernel.org/show_bug.cgi?id=12868 .

> On Monday 2009-03-09 14:14, Rafael J. Wysocki wrote:
> 
> >Hi,
> >
> >On Monday 09 March 2009, Jan Engelhardt wrote:
> >> Hi,
> >> 
> >> 
> >> commit 1326c3d5a4b792a2b15877feb7fb691f8945d203 
> >> (v2.6.28-rc6-461-g23a12b1) broke the display of local and remote 
> >> addresses of an SIT tunnel in iproute2. Instead of the addresses 
> >> assigned, it only displays 0.0.0.0. The version of iproute2 is 2.6.25, 
> >> as shipped with openSUSE 11.1.
> >> 
> >> Before:
> >> # ip t a sit7 mode sit remote 1.2.3.4 local 5.6.7.8
> >> # ip a
> >> 7: sit7@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop stat DOWN
> >>     link/sit 5.6.7.8 peer 1.2.3.4
> >> 
> >> After:
> >> 7: sit7@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop stat DOWN
> >>     link/sit 0.0.0.0 brd 0.0.0.0
> >> 
> >> ---->
> >> commit 23a12b14715e2dcd34dc8002927263ad3437344c
> >> Author: Stephen Hemminger <shemminger@vyatta.com>
> >> Date:   Thu Nov 20 20:33:56 2008 -0800
> >> 
> >>     ipv6: convert tunnels to net_device_ops
> >>     
> >>     Like IPV4, convert the tunnel virtual devices to use net_device_ops.
> >>     
> >>     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >>     Signed-off-by: David S. Miller <davem@davemloft.net>
> >> 
> >> :040000 040000 23483d156e517904d31dd7e2276a0ff8a25f2ecc 
> >> 395574b3a80869307a5e936a02598476f7e1c49b M      net
> >> <----
> >
> >If you want me to track this, please send a copy to a mailing list with
> >archives to which I can link or file a bugzilla report (with CC to me).

Thanks,
Rafael
