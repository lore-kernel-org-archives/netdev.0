From: "Arno J. Klaassen" <arno@heho.snv.jussieu.fr>
Subject: Re: [Bugme-new] [Bug 11752] New: Extremely low	netperf	UDP_RR	throughput for nvidia MCP65
Date: 11 Dec 2008 21:53:36 +0100
Message-ID: <wpfxkuo2lr.fsf@heho.snv.jussieu.fr>
References: <bug-11752-10286@http.bugzilla.kernel.org/>
	<20081016134920.1492cdcc.akpm@linux-foundation.org>
	<48F7AD1A.7050309@hp.com> <wp63nrx7zk.fsf@heho.snv.jussieu.fr>
	<48F8FE18.6060005@hp.com> <wpprlyuoci.fsf@heho.snv.jussieu.fr>
	<48FCC2C1.5030108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:64988 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757365AbYLKWFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 17:05:52 -0500
In-Reply-To: <48FCC2C1.5030108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

Rick Jones <rick.jones2@hp.com> writes:

> >>Clearly something is fubar with the rx side (well duh :).  The next
> >>set of stats I'd try to look at would be ethtool stats for the
> >>interface, eg ethtool -S eth0 and see if it shows someting more
> >>specific for the "RX-ERR" shown by netstat -I eth0.
> > OK, here it is (rx_errors_total: 10049, rx_crc_errors: 10049) :
> 
> Well, that seems to confirm that it is CRC errors.

[ .. stuff deleted .. ]

well, just a quick 'knock knock' in case any of you has something
new on this

I can live with 100Mbps, but would be glad to help further to
get it work at 1gbps (pavillon dv6700).
Looks like a silicon bug to me, but alas; please beep me if
I can test something.

Best regards, Arno
