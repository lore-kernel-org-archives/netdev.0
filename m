From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH 2/2][net-next] gianfar: Add ethtool -A support for pause
 frame
Date: Fri, 9 Aug 2013 13:12:15 +0300
Message-ID: <5204C07F.9050703@freescale.com>
References: <1375987549.2853.67.camel@deadeye.wl.decadent.org.uk> <1376036790-18238-1-git-send-email-ljaenicke@innominate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Lutz Jaenicke <ljaenicke@innominate.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0252.outbound.messaging.microsoft.com ([213.199.154.252]:8109
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753459Ab3HIKMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 06:12:37 -0400
In-Reply-To: <1376036790-18238-1-git-send-email-ljaenicke@innominate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks,

First patch seems to include the complete implementation of ethtool -A,
fixing the pause issue for half-duplex links as well, and it also
implements pause autoneg. (nice)
I'm going to apply an test this code and re-spin the resulting
patch(es).
Are you the author of this patch?
(gianfar: implement flow control handling)

Claudiu

On 8/9/2013 11:26 AM, Lutz Jaenicke wrote:
> I have been working on the same issue and came up with a similar
> modification (that additionally implements LFC if supported)
> I have attached the two patches created:
> * gianfar: implement flow control handling
>    which looks quite similar to Claudiu's patches
> * gianfar: add support for LFC (Lossless Flow Control)
>    which is more or less just extracted from some patch I found on the internet
>      linux-2.6.29.6-mpc8308e_rdb.patch
> The patches I have taken from a custom 3.4 based kernel so they may not
> apply cleanly but maybe bits of it can be used to generate fully supported
> solution.
>
>
