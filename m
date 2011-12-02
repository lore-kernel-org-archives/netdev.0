From: Michal Soltys <soltys@ziu.info>
Subject: Re: ebtables on a stick
Date: Fri, 02 Dec 2011 17:44:03 +0100
Message-ID: <4ED90053.4020203@ziu.info>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com> <20111201071456.GJ589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com> <20111201144745.GK589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com> <20111201165040.GL589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048FA@mail733.InfraSupportEtc.com> <4ED8F15D.8020909@ziu.info> <925A849792280C4E80C5461017A4B8A2A0491B@mail733.InfraSupp
 ortEtc.com> <4ED8F9CC.9000308@ziu.info> <925A849792280C4E80C5461017A4B8A2A0491E@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3237 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755788Ab1LBQoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 11:44:03 -0500
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A0491E@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-02 17:20, Greg Scott wrote:
> OK.  But I dunno....  I set eth0 on the router with the same address as
> the real host behind it on eth1.  So something comes in on eth0 for
> 1.2.115.157.  The router has that as its own address now, plus a route
> to somebody else with the same address on eth1.  But as far as the
> router/firewall is concerned, that packet is already delivered - why
> would it forward it out on eth1?
>

Where the packet gets delivered is decided by the routing - and the very 
first table traversed is local - which is auto filled by the kernel. But 
that routing rule still can be forcibly removed, after which the next 
matching one is the one added manually - after which the packet will end 
in FORWARD, instead of INPUT.

(and keep in mind earlier David's warning about confusing 
programs/services - it's still doable, but requires more manual labor - 
proxy is certianly cleaner and just works)
