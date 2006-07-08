From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Sat, 08 Jul 2006 04:48:29 +0200
Message-ID: <44AF1CFD.102@trash.net>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44AE15C3.8050900@trash.net> <44AEA462.1080505@candelatech.com> <44AEBCE7.2030203@trash.net> <44AF053F.70605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>, Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62451 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932405AbWGHCsb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 22:48:31 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <44AF053F.70605@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> With this patch applied everything is looking much better.  I currently
> have 400+ interfaces and one routing table per interface, and traffic
> is passing as expected.
> 
> This is probably due to my own application polling interfaces for
> stat updates...but I am seeing over 50% usage (with more system than
> user-space)
> in this setup on an otherwise lightly loaded system.  top shows no
> process averaging
> more than about 2% CPU (and only 2-3 are above 0.0 typically), which I find
> a little strange.  load is around 3.0.

I can't imagine this beeing related to the increased number of
routing tables, with a number of entries slightly (not even two
times) over the hash size it shouldn't make that much of a
difference. It may of course be a bug, but I don't see it.

