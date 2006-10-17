From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/14] [TIPC] Debug print buffer enhancements and fixes
Date: Mon, 16 Oct 2006 21:43:17 -0700 (PDT)
Message-ID: <20061016.214317.21930269.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<11607394754031-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10409
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423040AbWJQEnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:43:18 -0400
To: per.liden@ericsson.com
In-Reply-To: <11607394754031-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:43 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> This change modifies TIPC's print buffer code as follows:
> 1) Now supports small print buffers (min. size reduced from 512 bytes to 64)
> 2) Now uses TIPC_NULL print buffer structure to indicate null device
>    instead of NULL pointer (this simplified error handling)
> 3) Fixed misuse of console buffer structure by tipc_dump()
> 4) Added and corrected comments in various places
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, please run trailing-whitespace checks on your patches,
f.e. using "git apply --check --whitespace=error-all diff".
Because often I have to fix up problems like the following in
your submissions:

davem@sunset:~/src/GIT/net-2.6$ pcheck diff
+ git apply --check --whitespace=error-all diff
Adds trailing whitespace.
diff:25: * TIPC_LOG		   : TIPC log buffer 
Adds trailing whitespace.
diff:105: * 
Adds trailing whitespace.
diff:148: * 
Adds trailing whitespace.
diff:334:			printk("\n---- Start of %s log dump ----\n\n", 
Adds trailing whitespace.
diff:366:		tipc_printbuf_init(TIPC_LOG, kmalloc(log_size, GFP_ATOMIC), 
Adds trailing whitespace.
diff:393: * @next: used to link print buffers when printing to more than one at a time 
Adds trailing whitespace.
diff:395: 
fatal: 7 lines add trailing whitespaces.

Thanks.
