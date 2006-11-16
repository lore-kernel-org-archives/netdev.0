From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [patch 07/30] bcm43xx: Drain TX status before starting IRQs
Date: Thu, 16 Nov 2006 10:09:29 -0600
Message-ID: <455C8D39.3080001@lwfinger.net>
References: <20061116024332.124753000@sous-sol.org> <20061116024511.458086000@sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, stable@kernel.org,
	Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	mb@bu3sch.de, greg@kroah.com,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:63935 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1424250AbWKPQKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 11:10:13 -0500
To: Chris Wright <chrisw@sous-sol.org>
In-Reply-To: <20061116024511.458086000@sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Wright wrote:
> -stable review patch.  If anyone has any objections, please let us know.
> ------------------
> 
> From: Michael Buesch <mb@bu3sch.de>
> 
> Drain the Microcode TX-status-FIFO before we enable IRQs.
> This is required, because the FIFO may still have entries left
> from a previous run. Those would immediately fire after enabling
> IRQs and would lead to an oops in the DMA TXstatus handling code.
> 
> Cc: "John W. Linville" <linville@tuxdriver.com>
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>
> ---

Chris,

We have a report of a regression between 2.6.19-rc3 and -rc5. As this patch seems to be the only one 
that could cause the problem, please pull it from -stable while we sort out the difficulty.

Thanks,

Larry

