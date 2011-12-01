From: Michal Soltys <soltys@ziu.info>
Subject: Re: ebtables on a stick
Date: Thu, 01 Dec 2011 18:44:08 +0100
Message-ID: <4ED7BCE8.1040307@ziu.info>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:1904 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755751Ab1LARoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 12:44:13 -0500
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-01 06:46, Greg Scott wrote:
> Well this is frustrating.  Now my public host can communicate anywhere
> it wants internally but nothing outside. Maddening - the exact
> opposite problem I had before.
> 
> 
> $IPTABLES -A FORWARD -s 1.2.115.157 -j ACCEPT
> $IPTABLES -A FORWARD -s 192.168.10.0/24 -d 1.2.115.157 -j ACCEPT
> $IPTABLES -A FORWARD -p TCP --dport 1720 -d $ADR -j allowed
> $IPTABLES -A FORWARD -p TCP -s $MGMT_IP -d $ADR -j allowed
> 

And accepting traffic to 1.2.115.157 from the outside ? Are there any -m
state / -m conntrack --ctstate entries in your rules ?
