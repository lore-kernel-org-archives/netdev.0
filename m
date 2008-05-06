From: Ben Liblit <liblit@acm.org>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Mon, 05 May 2008 20:24:15 -0500
Message-ID: <481FB33F.3040804@acm.org>
References: <bug-10600-10286@http.bugzilla.kernel.org/> <20080505155502.3fb16590.akpm@linux-foundation.org> <20080505.161806.267621711.davem@davemloft.net> <481F9E64.6070606@acm.org> <1210036624.7941.183.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.sbc.mail.mud.yahoo.com ([68.142.198.203]:20865 "HELO
	smtp104.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753043AbYEFBa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 21:30:57 -0400
In-Reply-To: <1210036624.7941.183.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> "ethtool -C eth0 stats-block-usecs" can be used to control statistics
> update frequency on most tg3 and bnx2 devices.

But not on my e1000-driven Intel 82566DC, sadly:

	# ethtool -C eth0 stats-block-usecs 50
	Cannot get device coalesce settings: Operation not supported

	# ethtool -c eth0
	Coalesce parameters for eth0:
	Cannot get device coalesce settings: Operation not supported
