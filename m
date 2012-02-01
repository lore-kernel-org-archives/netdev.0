From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 1 Feb 2012 18:14:15 +0000
Message-ID: <1328120055.2541.5.camel@bwh-desktop>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	 <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	 <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	 <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	 <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
	 <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
	 <CADDf=MRuAWRFWMiCOOkWBzhW7_B3wRoMEpmk8ij=SxD2QvP3mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Leonardo Uzcudun <uzcudunl@yahoo.it>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: yao zhao <yao.development@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:62729 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753157Ab2BASOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 13:14:19 -0500
In-Reply-To: <CADDf=MRuAWRFWMiCOOkWBzhW7_B3wRoMEpmk8ij=SxD2QvP3mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-01 at 12:25 -0500, yao zhao wrote:
> How about this?
> 
> brctl addif br_vlan_1 eth0 eth1

Right, VID 1 is not special to Linux.

> brctl addif br_vlan_101 eth0.101 eth2.101

I think you mean eth2 rather than eth2.101.

This should work on:
1. Linux 2.6.36 and earlier, if eth0 has VLAN tag offload.
2. Linux 3.2 and later.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
