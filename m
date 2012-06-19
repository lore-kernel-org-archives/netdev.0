From: <Parav.Pandit@Emulex.Com>
Subject: RE: [PATCH] net: added support for 40GbE link.
Date: Tue, 19 Jun 2012 07:42:31 +0000
Message-ID: <5D6C0ABE6A236946864C45679362BBE20AC5227D@CMEXMB1.ad.emulex.com>
References: <1340039376.2913.13.camel@bwh-desktop.uk.solarflarecom.com>
	<20120619.002905.922583388766089167.davem@davemloft.net>
	<5D6C0ABE6A236946864C45679362BBE20AC52269@CMEXMB1.ad.emulex.com>
 <20120619.003517.2067426285873138772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <bhutchings@solarflare.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:15462 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751878Ab2FSHmv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 03:42:51 -0400
In-Reply-To: <20120619.003517.2067426285873138772.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, June 19, 2012 1:05 PM
> To: Pandit, Parav
> Cc: bhutchings@solarflare.com; netdev@vger.kernel.org
> Subject: Re: [PATCH] net: added support for 40GbE link.
> 
> From: <Parav.Pandit@Emulex.Com>
> Date: Tue, 19 Jun 2012 07:33:12 +0000
> 
> > Should eventually all net driver should remove using SPEED_xxxxxx and
> start using hard coded value of 10, 100, 1000, 20000?
> 
> No, the ones that exist can stay, just no new ones.
> 
So driver which supports 40Gpbs, 100Gbps should hardcode to 40000, 100000 respectively?

> > That means ethtool_cmd_speed() should not be called in this function?
> 
> Ben said that it must be called, what are you talking about?

Sorry, I wanted to ask - Do you need switch case for speed like below new code or its should be speed independent code?
                switch (ethtool_cmd_speed()) {
                case SPEED_100:
                case SPEED_10:
                        return DEFAULT_PRB_RETIRE_TOV;
                default:
                        msec = 1;
                        div = ethtool_cmd_speed() / 1000;
                        break;
                /*
                }
