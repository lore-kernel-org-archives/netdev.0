From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ec_bhf: Add runtime dependencies
Date: Fri, 30 May 2014 16:32:16 -0700 (PDT)
Message-ID: <20140530.163216.1223406878883458972.davem@davemloft.net>
References: <20140526212614.6e2610b0@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, reksio@newterm.pl
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934636AbaE3XcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 19:32:17 -0400
In-Reply-To: <20140526212614.6e2610b0@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Mon, 26 May 2014 21:26:14 +0200

> The ec_bhf driver is specific to the Beckhoff CX5020, an embedded PC
> based on a 32-bit Intel Atom CPU. So we can add a dependency on
> X86_32, with COMPILE_TEST as an alternative to still allow for broader
> build-testing.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Please follow Darek's recommendationa and allow X86_64 as well.

Thanks.
