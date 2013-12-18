From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: ptp: Include new header file in ptp_pch.c
Date: Wed, 18 Dec 2013 17:43:59 -0500 (EST)
Message-ID: <20131218.174359.2230195267384857675.davem@davemloft.net>
References: <1387140255-11797-1-git-send-email-rashika.kheria@gmail.com>
	<20131216085839.GA8303@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rashika.kheria@gmail.com, linux-kernel@vger.kernel.org,
	dvhart@linux.intel.com, joe@perches.com,
	andriy.shevchenko@linux.intel.com, vfalico@redhat.com,
	netdev@vger.kernel.org, josh@joshtriplett.org
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131216085839.GA8303@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 16 Dec 2013 09:58:40 +0100

> On Mon, Dec 16, 2013 at 02:14:15AM +0530, Rashika Kheria wrote:
>> ---
>>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    9 ---------
>>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    1 +
>>  drivers/ptp/ptp_pch.c                              |    1 +
>>  include/linux/ptp_pch.h                            |   16 ++++++++++++++++
>>  4 files changed, 18 insertions(+), 9 deletions(-)
>>  create mode 100644 include/linux/ptp_pch.h
> 
> Instead of adding a random driver header into include/linux, I would
> prefer that you just move the ptp_pch.c from drivers/ptp to
> drivers/net/ethernet/oki-semi/pch_gbe. Then you can just include
> pch_gbe.h directly.

I think this begs an even more fundamental question, why isn't the PTP
driver abstraction providing the necessary methods and interfaces so
that pch_gbe doesn't have to call into the ptp_pch.c code directly?

Moving ptp_pch.c elsehwere is not desirable, it's a PTP driver so
it belongs under drivers/ptp.

Someone who understands all of these components needs to sort this
out cleanly, this patch isn't it.
