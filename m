From: Michal Soltys <soltys@ziu.info>
Subject: Re: ebtables on a stick
Date: Fri, 02 Dec 2011 17:16:12 +0100
Message-ID: <4ED8F9CC.9000308@ziu.info>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com> <20111201071456.GJ589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com> <20111201144745.GK589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com> <20111201165040.GL589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048FA@mail733.InfraSupportEtc.com> <4ED8F15D.8020909@ziu.info> <925A849792280C4E80C5461017A4B8A2A0491B@mail733.InfraSupp
 ortEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3056 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756948Ab1LBQQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 11:16:11 -0500
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A0491B@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
