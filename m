From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Fri, 8 Jun 2007 21:05:10 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D66D@nekter>
References: <D5C1322C3E673F459512FB59E0DDC32902FFC730@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <jeff@garzik.org>,
	<kaber@trash.net>, <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"David Miller" <davem@davemloft.net>, <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:13030 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054AbXFIBHZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 21:07:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902FFC730@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter,

Where is your git tree located? 

Ram
> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Waskiewicz Jr, Peter P
> Sent: Thursday, June 07, 2007 3:56 PM
> To: David Miller; hadi@cyberus.ca
> Cc: Kok, Auke-jan H; jeff@garzik.org; kaber@trash.net;
> netdev@vger.kernel.org; Brandeburg, Jesse
> Subject: RE: [PATCH] NET: Multiqueue network device support.
> 
> > > I empathize but take a closer look; seems mostly useless.
> >
> > I thought E1000 still uses LLTX, and if so then multiple cpus
> > can most definitely get into the ->hard_start_xmit() in parallel.
> 
> Not with how the qdisc status protects it today:
> 
> include/net/pkt_sched.h:
> 
> static inline void qdisc_run(struct net_device *dev)
> {
>         if (!netif_queue_stopped(dev) &&
>             !test_and_set_bit(__LINK_STATE_QDISC_RUNNING,
&dev->state))
>                 __qdisc_run(dev);
> }
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
