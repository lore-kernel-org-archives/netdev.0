From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Wed, 22 Nov 2006 02:01:34 -0500
Message-ID: <200611220201.34717.dtor@insightbb.com>
References: <200610031457.33215.chunkeey@web.de> <200611172327.49477.dtor@insightbb.com> <200611181118.02549.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:41406 "EHLO
	asav14.insightbb.com") by vger.kernel.org with ESMTP
	id S1756931AbWKVHBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 02:01:38 -0500
To: chunkeey@web.de
In-Reply-To: <200611181118.02549.chunkeey@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 18 November 2006 05:18, chunkeey@web.de wrote:
> Am Samstag, 18. November 2006 05:27 schrieben Sie:
> >
> > OK, i'll try installing kismet on another laptop. For now that's what I
> > have from iwevent:
> >
> > [root@core ~]# cat iwevents.bad
> > 21:30:52.185823   eth1     Set Mode:Managed
> where's Set Encryption key:****-****-****-****-****-****-**   Security 
> mode:restricted ? was the key set?
> 
> 
> > 21:30:52.226100   eth1     Set ESSID:"ALCT76_68b"
> > 21:30:54.505039   eth1     Authenticate request to XY [00 0D 0002]
> > 21:30:56.300128   eth1     Authenticate request to XY [00 0D 0002]
> ok, the error code is 0D (=unsupported Authentication Algorithm).
> 
> >
> > [root@core ~]# cat iwevents.good
> > 21:50:50.575630   eth1     Set Mode:Managed
> > 21:50:50.604998   eth1     Set Encryption
> > key:****-****-****-****-****-****-**   Security mode:restricted
> > 21:50:50.616502   eth1     Set ESSID:"ALCT76_68b"
> > 21:50:52.880361   eth1     Authenticate request to XY : [00  00 0002]
> > 21:50:52.882638   eth1     Associate request to XY : [00 00 0002]
> > 21:50:52.883625   eth1     New Access Point/Cell address:XY
> are your wireless-tools( iwconfig, iwevent, iwlist...) up to date? they've to 
> be atleast Version 21!
>

Hmm, something funky is going on with my hotplug scripts - if I rerun
ifup eth1 after inserting the card it associates just fine. Sorry for
the false alarm, the drivers seems to be working fine.

Still not sure why old driver does not need second "ifup"...

-- 
Dmitry
