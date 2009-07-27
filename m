From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] NET: ROSE: Don't use static buffer.
Date: Sun, 26 Jul 2009 19:11:25 -0700 (PDT)
Message-ID: <20090726.191125.253792670.davem@davemloft.net>
References: <cover.1248620197.git.ralf@linux-mips.org>
	<eb5a7590d64932b2239e358b54391c25007472ee.1248620197.git.ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <eb5a7590d64932b2239e358b54391c25007472ee.1248620197.git.ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sat, 25 Jul 2009 11:38:18 +0100

> The use of a static buffer in rose2asc() to return its result is not
> threadproof and can result in corruption if multiple threads are trying
> to use one of the procfs files based on rose2asc().
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Looks good, applied, thanks!
