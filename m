From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: ebtables on a stick
Date: Fri, 2 Dec 2011 10:20:01 -0600
Message-ID: <925A849792280C4E80C5461017A4B8A2A0491E@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com> <20111201071456.GJ589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com> <20111201144745.GK589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com> <20111201165040.GL589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048FA@mail733.InfraSupportEtc.com> <4ED8F15D.8020909@ziu.info> <925A849792280C4E80C5461017A4B8A2A0491B@mail733.InfraSupp
 ortEtc.com> <4ED8F9CC.9000308@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Lamparter" <equinox@diac24.net>, <netdev@vger.kernel.org>
To: "Michal Soltys" <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:59475 "EHLO
	mail.infrasupport.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757108Ab1LBQUD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 11:20:03 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK.  But I dunno....  I set eth0 on the router with the same address as
the real host behind it on eth1.  So something comes in on eth0 for
1.2.115.157.  The router has that as its own address now, plus a route
to somebody else with the same address on eth1.  But as far as the
router/firewall is concerned, that packet is already delivered - why
would it forward it out on eth1?

- Greg



-----Original Message-----
From: Michal Soltys [mailto:soltys@ziu.info] 
Sent: Friday, December 02, 2011 10:16 AM
To: Greg Scott
Cc: David Lamparter; netdev@vger.kernel.org
Subject: Re: ebtables on a stick

On 11-12-02 17:06, Greg Scott wrote:
>>  You should be able to avoid whole proxy thing altogether (on your
> router), by doing:
>>
>>  ip add add 1.2.115.157/32 dev eth0
>>  ip ro del table local 192.168.99.5/32 dev eth0 ip route add
> 1.2.115.157/32 dev eth1
>
> What's the 192.168.99.5/21 address?
>

Should be 1.2.115.157/32 (hasty copy paste).
