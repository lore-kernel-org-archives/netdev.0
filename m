From: "Rick Koshi" <netdev@more-right-rudder.com>
Subject: Re: Multiple GRE tunnels on the same host, only one routes incoming packets
Date: Sat, 11 Feb 2012 07:10:13 -0500
Message-ID: <201202111210.q1BCADqU026660@hope.more-right-rudder.com>
References: <201202111040.q1BAeESi014636@hope.more-right-rudder.com> <1328959799.5661.25.camel@edumazet-laptop>
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm23-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.141]:39178
	"HELO nm23-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754427Ab2BKMKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 07:10:17 -0500
In-reply-to: <1328959799.5661.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet writes:
> 
> check :
> 
> grep . `find /proc/sys -name rp_filter`

Thank you, thank you, thank you!  This is exactly right.
CentOS by default sets reverse-path filtering (which I'd
never even heard of before your message) partially on
(value 1 in /proc/sys/net/ipv4/conf/default/rp_filter).

In my case, I need it completely off for my 2 tunnel
interfaces.  A quick change to my setup script, and
everything works now.

Thank you so very much.  You have saved me hours
of frustration and given me a good night's sleep.  :-)

    -- Rick
