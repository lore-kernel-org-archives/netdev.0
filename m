From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 02:17:46 +0100
Message-ID: <467C74BA.9060809@simon.arlott.org.uk>
References: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "C. Scott Ananian" <cscott@laptop.org>, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:40287 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769AbXFWBRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 21:17:54 -0400
In-Reply-To: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/06/07 02:04, David Stevens wrote:
>         Why not make the application that writes resolv.conf
> also listen on a raw ICMPv6 socket? I don't believe you'd need
> any kernel changes, then, and it seems pretty simple and
> straightforward.

Because then it requires yet another network daemon, RA in 
the kernel means there's no need for one to manage adding 
auto-configured IP addresses... what's wrong with doing the 
same for DNS?

I don't think it should be in resolv.conf format though. Can't 
you make a change to glibc too to have it use it properly?

Something like "hosts: files rdnss dns" or an option that can 
be added to resolv.conf?

-- 
Simon Arlott
