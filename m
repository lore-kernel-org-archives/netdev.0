From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 4/4] Adds hardware supported cross timestamp
Date: Mon, 12 Oct 2015 19:31:52 -0700 (PDT)
Message-ID: <20151012.193152.903134353277818155.davem@davemloft.net>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
	<1444675522-4198-5-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org,
	x86@kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.b.stanton@intel.com
To: christopher.s.hall@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444675522-4198-5-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Date: Mon, 12 Oct 2015 11:45:22 -0700

> @@ -25,6 +25,8 @@
>   */
>  
>  #include "e1000.h"
> +#include <asm/tsc.h>

You cannot include an architecture specific header file in a driver
that's compiled on several architectures.
