From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: Re: [RFC] be2net: add rxhash support
Date: Fri, 25 Feb 2011 13:36:40 -0600
Message-ID: <20110225193640.GA11411@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:18087 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932644Ab1BYThF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 14:37:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Friday, February 25, 2011 1:33 PM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC] be2net: add rxhash support

> I added some traces, and I am not sure its OK :
> 
> With one active tcp flow, I got different rxhash values :
> 
> [ 1064.674253] rxhash=bbd37952 rsshp=1 bank=1
> [ 1064.738104] rxhash=37acd31d rsshp=1 bank=1
> [ 1064.741684] rxhash=bbd37952 rsshp=1 bank=1
> [ 1064.874283] rxhash=bbd37952 rsshp=1 bank=1
> [ 1064.940201] rxhash=bbd37952 rsshp=1 bank=1
> [ 1064.955278] rxhash=b668ace2 rsshp=1 bank=1
> [ 1065.080028] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.153360] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.293164] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.401862] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.460506] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.519980] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.650160] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.717585] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.730909] rxhash=37acd31d rsshp=1 bank=1
> [ 1065.840350] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.900704] rxhash=bbd37952 rsshp=1 bank=1
> [ 1065.931526] rxhash=b668ace2 rsshp=1 bank=1
> [ 1066.503657] rxhash=bbd37952 rsshp=1 bank=1
> [ 1066.570138] rxhash=bbd37952 rsshp=1 bank=1
> 
> How is it possible ?
> 
> (I have a VLAN config on top of a bonding)
> 
I'm looking at this..
There is no switch involved in your test, just back to back?

> 
> Also, Ajit, we need something to allow ethtool -K rxhash {on|off}
> 
> Something like (completely untested)

Yes. That is in the works.

Thanks
-Ajit
