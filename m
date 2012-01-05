From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 4/6] ath6kl: get rid of AR_DBG_LVL_CHECK()
Date: Thu, 5 Jan 2012 14:14:30 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF33@saturn3.aculab.com>
References: <20120105132812.22281.98859.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <sfr@canb.auug.org.au>, <netdev@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <ath6kl-devel@qualcomm.com>,
	<davem@davemloft.net>
To: "Kalle Valo" <kvalo@qca.qualcomm.com>, <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20120105132812.22281.98859.stgit@x201>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> We don't need it as debug calls already have a log level and compiler
> should be smart enough to optimise away the code when ath6kl 
> debug code is not enabled.

Have you checked?
I think you are assuming that because the called
function collapses, the call will be removed allowing
the loop to be removed.
I suspect this is only true if the function is inlined.
IIRC the normal linkage rules mean that only static
functions are candidates for inlining.

	David
