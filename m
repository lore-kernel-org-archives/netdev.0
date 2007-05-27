From: Michael Buesch <mb@bu3sch.de>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Sun, 27 May 2007 23:16:06 +0200
Message-ID: <200705272316.07338.mb@bu3sch.de>
References: <20070525172431.60affaca@freepuppy> <200705272125.25506.maxi@daemonizer.de> <200705272313.33129.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-wireless" <linux-wireless@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:36750
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756953AbXE0VQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 17:16:50 -0400
In-Reply-To: <200705272313.33129.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 27 May 2007 23:13:32 Michael Buesch wrote:
> On Sunday 27 May 2007 21:25:17 Maximilian Engelhardt wrote:
> > 2.6.21.1:
> > [  5] local 192.168.1.2 port 58414 connected with 192.168.1.1 port 5001
> > [  5]  0.0-60.6 sec  1.13 MBytes    157 Kbits/sec
> > [  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 57837
> > [  4]  0.0-63.1 sec  2.82 MBytes    375 Kbits/sec
> 
> > 2.6.22-rc3:
> > [  5] local 192.168.1.2 port 46557 connected with 192.168.1.1 port 5001
> > [  5]  0.0-60.4 sec  58.9 MBytes  8.18 Mbits/sec
> > [  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 51633
> > [  4]  0.0-63.1 sec  7.27 MBytes    967 Kbits/sec
> 
> This is the diff between these two kernels.
> I'm not sure why you see a much better TX throughput here.
> 
> Can you re-check to make sure it's not just some test-jitter?

Oh, eh, and what I forgot to ask:
Do you know an old kernel that works perfectly well for you,
so I can look at a diff between this one and anything >=2.6.21.1.

-- 
Greetings Michael.
