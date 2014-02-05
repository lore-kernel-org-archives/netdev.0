From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Wed, 05 Feb 2014 12:06:29 +0100
Message-ID: <52F21B35.9000502@omicron.at>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>	 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>	 <1391526492.7871.8.camel@e37108.spectralink.com>	 <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk>	 <20140205071250.GA4071@netboy> <1391595820.3003.60.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?IlPDuHJlbnNlbiwgU3RlZmFuIg==?=
	<Stefan.Sorensen@spectralink.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>
To: Ben Hutchings <ben@decadent.org.uk>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:55383 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbaBELGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 06:06:37 -0500
Received: by mail-ea0-f177.google.com with SMTP id n15so144362ead.22
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 03:06:36 -0800 (PST)
In-Reply-To: <1391595820.3003.60.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-02-05 11:23, Ben Hutchings wrote:
> On Wed, 2014-02-05 at 08:12 +0100, Richard Cochran wrote:
>> On Tue, Feb 04, 2014 at 09:51:59PM +0000, Ben Hutchings wrote:
>>>
>>> Right.  If all versions of CPSW include hardware timestamping then
>>> bother with PHY timestamping at all?  And why make CONFIG_TI_CPTS
>>> configurable?
>>
>> On the one hand, PHY time stamping is more accurate and offers
>> synchronization performance that is measurably better than MAC time
>> stamping.
>
> I suppose that depends on how much jitter there is in the PHY?

Not only jitter, asymmetries of the PHY delays must be well known, too,=
=20
and these data are not always available from datasheets.

If someone is interested in measurement results: We did a few=20
experiments last year for 100 Mbit Ethernet and compared MAC=20
timestamping of a P2020 with the PHY timestamping in the DP83640 (see=20
Table III in [1]).

Christian


[1] C. Riesch, C. Marinescu, and M. Rudigier, "Measurement of egress an=
d=20
ingress delays of PTP clocks", in 2013 International IEEE Symposium on=20
Precision Clock Synchronization for Measurement Control and=20
Communication (ISPCS), Lemgo, Germany, Sep. 22=E2=80=9327, 2013, pp. 11=
3=E2=80=93118.
http://www.riesch.at/christian/ISPCS2013_Measurement_of_egress_and_ingr=
ess_delays_of_PTP_clocks.pdf
