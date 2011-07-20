From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Remove "monitor" from "ip route help" output
Date: Wed, 20 Jul 2011 16:04:38 -0700
Message-ID: <20110720160438.08c053ff@nehalam.ftrdhcpuser.net>
References: <20110720150814.GA12025@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, martin f krafft <madduck@debian.org>,
	537681@bugs.debian.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51490 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338Ab1GTXEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 19:04:31 -0400
In-Reply-To: <20110720150814.GA12025@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jul 2011 17:08:14 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> $ ip route help 2>&1 | grep monitor
> ip route { add | del | change | append | replace | monitor } ROUTE
> $ ip route monitor
> Command "monitor" is unknown, try "ip route help".
> 
> (I guess what was really intended is "ip monitor route", so just remove
> the argument from the help output.)
> 
> Originally reported by martin f krafft at http://bugs.debian.org/537681
> 
> While at it, also drop all non-existant (route,link,netns) monitor
> arguments from the ip(8) man page.
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Applied
