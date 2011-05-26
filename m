From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [PATCH] iproute2: Add processless network namespace support.
Date: Thu, 26 May 2011 15:35:15 -0600
Message-ID: <4DDEC793.8040502@genband.com>
References: <m1hb8hyyaj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og111.obsmtp.com ([64.18.2.175]:38304 "EHLO
	exprod7og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757892Ab1EZVgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 17:36:04 -0400
In-Reply-To: <m1hb8hyyaj.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2011 02:58 PM, Eric W. Biederman wrote:
>
> The goal of this code change is to implement a mechanism such that it is
> simple to work with a kernel that is using multiple network namespaces
> at once.
>
> This comes in handy for interacting with vpns where there may be rfc1918
> address overlaps, and different policies default routes, name servers
> and the like.
>
> Configuration specific to a network namespace that would ordinarily be
> stored under /etc/ is stored under /etc/netns/<name>.  For example if
> the dns server configuration is different for your vpn you would create
> a file /etc/netns/myvpn/resolv.conf.

That would be interesting.  Currently I use dnsmasq to keep my DNS 
servers straight when connecting in to two different corporate VPNs 
simultaneously.

I could see it being interesting trying to remember which shell sessions 
were running in which network namespace...

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
