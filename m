From: Dragos Ilie <dragos.ilie@gmail.com>
Subject: Re: Premature timeout for MLDv1 Host compatibility mode?
Date: Thu, 2 Aug 2012 16:03:24 +0200
Message-ID: <CAOLNa-cMkHaFxoWym-oVT6i7ZZ25tZPxaAEcwUuT1TB4kPGfag@mail.gmail.com>
References: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>
	<OFB6FB6105.8DE1252A-ON85257A4E.004637D4-85257A4E.00474EEF@us.ibm.com>
	<CAOLNa-dj1N-3Lo6Bu8X4H51gxBs4B2V0qWSDFQ-2qQzjEApJfw@mail.gmail.com>
	<OF675087EF.EDC93ADE-ON85257A4E.004B2D96-85257A4E.004CB6BE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:57888 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab2HBODY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 10:03:24 -0400
In-Reply-To: <OF675087EF.EDC93ADE-ON85257A4E.004B2D96-85257A4E.004CB6BE@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 2, 2012 at 3:57 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> Dragos Ilie <dragos.ilie@gmail.com> wrote on 08/02/2012 09:28:49 AM:
>
>> MLDv1 packets do not have a QQIC field in the Query header. That is a
>> available for MLDv2 only. Consequently, MLDv1 queriers should fallback
>>  on the Query Interval variable, which has a  default value of 125
>> seconds. Since the Query Interval value is not user-configurable, I
>> assume that using the default value is a reasonable choice.
>
> The QQIC would come from v2 queries prior to the v1 query that
> triggered us to switch to v1. But, see below.

How about the scenario where you have only MLDv1 queriers? There will
be no prior v2 query

>
>> RFC 3810(MLDv2)  does mention that the Older Version Querier Present
>> Timeout must be calculated using the Query Interval from the last
>> received Query. I think the RFC is wrong on that point because I don't
>> see how a MLDv1 querier can convey its Query Interval to a listener.
>
> I'll look through this some more. I think using a fixed timeout
> is a bad idea since it doesn't account for shorter or longer interval
> queriers intentionally configured that way. Ideally it should,
> of course, be a positive indication that the v1 querier is gone
> based on v1 querier data (your point).
>
>                                                 +-DLS
>
