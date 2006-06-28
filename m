From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Wed, 28 Jun 2006 12:14:28 +0200
Message-ID: <44A25684.3070105@fr.ibm.com>
References: <20060609210625.144158000@localhost.localdomain>	<20060626134711.A28729@castle.nmd.msu.ru>	<449FF5A0.2000403@fr.ibm.com> <20060626192751.A989@castle.nmd.msu.ru>	<44A00215.2040608@fr.ibm.com>	<20060627131136.B13959@castle.nmd.msu.ru>	<44A0FBAC.7020107@fr.ibm.com> <44A1006B.3040700@sw.ru>	<20060627160908.GC28984@MAIL.13thfloor.at>	<m1y7vilfyk.fsf@ebiederm.dsl.xmission.com>	<20060627230723.GC2612@MAIL.13thfloor.at> <m1irmlkjni.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Poetzl <herbert@13thfloor.at>, Kirill Korotaev <dev@sw.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrey Savochkin <saw@swsoft.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com,
	Andrew Morton <akpm@osdl.org>, devel@openvz.org,
	sam@vilain.net, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:24026 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S932538AbWF1KOi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 06:14:38 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1irmlkjni.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi !

Eric W. Biederman wrote:

[ ... ]

> So just to sink one additional nail in the coffin of the silly
> guest to guest communication issue.  For any two guests where
> fast communication between them is really important I can run
> an additional interface pair that requires no routing or bridging.
> Given that the implementation of the tunnel device is essentially
> the same as the loopback interface and that I make only one
> trip through the network stack there will be no performance overhead.
> Similarly for any critical guest communication to the outside world
> I can give the guest a real network adapter.
> 
> That said I don't think those things will be necessary and that if
> they are it is an optimization opportunity to make various bits
> of the network stack faster.

just one comment on the 'guest to guest communication' topic :

guest to guest communication is an important factor in consolidation
scenarios, where containers are packed on one server. This for maintenance
issues or priority issues on a HPC cluster for example. This case of
container migration is problably the most interesting and the performance
should be more than acceptable. May be not a top priority for the moment.


thanks,

C.
