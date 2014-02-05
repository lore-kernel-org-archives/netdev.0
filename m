From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Wed, 05 Feb 2014 11:49:57 +0100
Message-ID: <52F21755.90101@omicron.at>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>	 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>	 <1391526492.7871.8.camel@e37108.spectralink.com>	 <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk> <1391585274.7871.19.camel@e37108.spectralink.com> <52F1F3E3.2050906@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>,
	=?UTF-8?B?IlPDuHJlbnNlbiwgU3RlZmE=?= =?UTF-8?B?biI=?=
	<Stefan.Sorensen@spectralink.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57190 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbaBEKvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 05:51:05 -0500
Received: by mail-wi0-f178.google.com with SMTP id cc10so401372wib.5
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 02:51:04 -0800 (PST)
In-Reply-To: <52F1F3E3.2050906@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-02-05 09:18, Mugunthan V N wrote:
> On Wednesday 05 February 2014 12:58 PM, S=C3=B8rensen, Stefan wrote:
>> The CPSW only supports timestamping which is only one part of the PT=
P
>> functionality. Some PHYs (like the dp83630 that we use with the CPSW=
)
>> also has external event generation and detection.
> CPSW also has External event detection upto 4 events and newer SoCs u=
pto
> 8 events, currently no boards came with this pins pinned out, so it i=
s
> not supported as of now. If we have a board design with this we can
> support external event generation.

But for external event generation it would be useful to adjust the cloc=
k=20
frequency of the PHC. IIRC this is broken on some silicon like the=20
AM335x, right?

Christian
