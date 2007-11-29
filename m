From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 0/3] cxgb - driver fixes.
Date: Thu, 29 Nov 2007 10:25:38 -0800
Message-ID: <474F0422.6090309@candelatech.com>
References: <474C8BF8.9080609@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761952AbXK2S0M@vger.kernel.org>
In-Reply-To: <474C8BF8.9080609@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> Jeff,
> 
> I'm submitting a patch series for inclusion in 2.6.24 for the cxgb driver.
> The patches are built against Linus'git tree.
> 
> Here is a brief description:
> - Ensure that GSO skbs have enough headroom before encapsulating them,
> - Fix a crash in NAPI mode,
> - Fix statistics accounting and report.

We ran pktgen overnight on 2.6.23 with patch 1 and 3 applied (patch 2
not needed on .23 it seems) and it was stable at about 1.5Gbps bi-directional
using 1500 MTU sized frames.

We'll run some more tests with user-space TCP & UDP today, but it looks good
so far.

Perhaps these patches should be considered for .23 stable as well?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
