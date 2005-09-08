From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [AX.25] Make asc2ax thread-proof
Date: Thu, 08 Sep 2005 13:41:12 -0700 (PDT)
Message-ID: <20050908.134112.107447708.davem@davemloft.net>
References: <20050907143401.GC3493@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: ralf@linux-mips.org
In-Reply-To: <20050907143401.GC3493@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Date: Wed, 7 Sep 2005 15:34:01 +0100

> Asc2ax was still using a static buffer for all invocations which isn't
> exactly SMP-safe.  Change asc2ax to take an additional result buffer as
> the argument.  Change all callers to provide such a buffer.
> 
> This one only really is a fix for ROSE and as per recent discussions
> there's still much more to fix in ROSE ...
> 
> Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

Applied, thanks Ralf.
