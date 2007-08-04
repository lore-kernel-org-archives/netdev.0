From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Fri, 03 Aug 2007 20:57:09 -0700 (PDT)
Message-ID: <20070803.205709.126573435.davem@davemloft.net>
References: <200708021115.10812.joachim.deguara@amd.com>
	<20070802.022317.66176729.davem@davemloft.net>
	<1186081829.18322.20.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joachim.deguara@amd.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1186081829.18322.20.camel@dell>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 02 Aug 2007 12:10:29 -0700

> [TG3]: Fix suspend/resume problem.
> 
> Joachim Deguara <joachim.deguara@amd.com> reported that tg3 devices
> would not resume properly if the device was shutdown before the system
> was suspended.  In such scenario where the netif_running state is 0,
> tg3_suspend() would not save the PCI state and so the memory enable bit
> and bus master enable bit would be lost.
> 
> We fix this by always saving and restoring the PCI state in
> tg3_suspend() and tg3_resume() regardless of netif_running() state.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Patch applied.
