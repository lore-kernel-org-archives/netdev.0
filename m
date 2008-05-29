From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Thu, 29 May 2008 15:08:24 +0200
Message-ID: <20080529130823.GA8364@elte.hu>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:41517 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbYE2NIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 09:08:51 -0400
Content-Disposition: inline
In-Reply-To: <20080529112257.GA18130@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


btw., i now also have a hung socket over real network:

titan:~> netstat -nt
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State
tcp        0  86752 10.0.1.14:49921             10.0.1.16:3632              ESTABLISHED

(the scenario is similar to the incident i've analyzed before, so i wont 
repeat the tcpdump, etc.)

	Ingo
