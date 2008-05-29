From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Thu, 29 May 2008 13:22:57 +0200
Message-ID: <20080529112257.GA18130@elte.hu>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:43020 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768AbYE2LXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 07:23:24 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


after about 50 bootups i got a hung test again:

titan:~/tip> netstat -nt
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             
State
tcp        0      0 10.0.1.14:22                10.0.1.16:58062  ESTABLISHED
tcp        0      0 10.0.1.14:22                10.0.1.16:60109  ESTABLISHED
tcp        0  86368 10.0.1.14:43914             10.0.1.16:3632   ESTABLISHED

and this time with CUBIC_TCP disabled - so that was a red herring.

	Ingo
