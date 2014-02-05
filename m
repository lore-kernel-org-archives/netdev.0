From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Wed, 5 Feb 2014 19:45:34 +0530
Message-ID: <52F24786.3020306@ti.com>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>	 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>	 <1391526492.7871.8.camel@e37108.spectralink.com>	 <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk> <1391585274.7871.19.camel@e37108.spectralink.com> <52F1F3E3.2050906@ti.com> <52F21755.90101@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christian Riesch <christian.riesch@omicron.at>,
	=?UTF-8?B?IlPDuHJlbnNl?= =?UTF-8?B?biwgU3RlZmFuIg==?=
	<Stefan.Sorensen@spectralink.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:35096 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344AbaBEOQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Feb 2014 09:16:08 -0500
In-Reply-To: <52F21755.90101@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 February 2014 04:19 PM, Christian Riesch wrote:
> On 2014-02-05 09:18, Mugunthan V N wrote:
>> On Wednesday 05 February 2014 12:58 PM, S=C3=B8rensen, Stefan wrote:
>>> The CPSW only supports timestamping which is only one part of the P=
TP
>>> functionality. Some PHYs (like the dp83630 that we use with the CPS=
W)
>>> also has external event generation and detection.
>> CPSW also has External event detection upto 4 events and newer SoCs =
upto
>> 8 events, currently no boards came with this pins pinned out, so it =
is
>> not supported as of now. If we have a board design with this we can
>> support external event generation.
>
> But for external event generation it would be useful to adjust the
> clock frequency of the PHC. IIRC this is broken on some silicon like
> the AM335x, right?
>

Yes, I agree but it is fixed in future SoCs like DRA7xx and AM43xx

Regards
Mugunthan V N
