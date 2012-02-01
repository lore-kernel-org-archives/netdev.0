From: yao zhao <yao.development@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 1 Feb 2012 15:52:17 -0500
Message-ID: <CADDf=MRvCyvEtWGAvPV29uCeoTrDTbjyi0g-q5Qj1zVPDOLYrA@mail.gmail.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	<1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	<1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	<CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	<1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
	<1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
	<CADDf=MRuAWRFWMiCOOkWBzhW7_B3wRoMEpmk8ij=SxD2QvP3mw@mail.gmail.com>
	<1328120055.2541.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Leonardo Uzcudun <uzcudunl@yahoo.it>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:37671 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932095Ab2BAUxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 15:53:03 -0500
Received: by obcva7 with SMTP id va7so1780703obc.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 12:53:02 -0800 (PST)
In-Reply-To: <1328120055.2541.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2012 at 1:14 PM, Ben Hutchings <bhutchings@solarflare.com> wrote:
> On Wed, 2012-02-01 at 12:25 -0500, yao zhao wrote:
>> How about this?
>>
>> brctl addif br_vlan_1 eth0 eth1
>
> Right, VID 1 is not special to Linux.
>
>> brctl addif br_vlan_101 eth0.101 eth2.101
>
> I think you mean eth2 rather than eth2.101.
>
I guess he means vlan 101 is tagged on eth2, if not (connected to
host, access port) then you are right.

> This should work on:
> 1. Linux 2.6.36 and earlier, if eth0 has VLAN tag offload.
> 2. Linux 3.2 and later.
>
Any reason?

> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
