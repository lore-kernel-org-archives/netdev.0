From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 13:48:04 -0700 (PDT)
Message-ID: <20070411.134804.50594117.davem@davemloft.net>
References: <461D2DEA.4010806@candelatech.com>
	<461D447C.4070408@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44348
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1160998AbXDKUsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 16:48:03 -0400
In-Reply-To: <461D447C.4070408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 11 Apr 2007 13:26:36 -0700

> Interestingly, I found this page mentioning a SACK problem in Linux:
> http://www-didc.lbl.gov/TCP-tuning/linux.html

Don't read that page, it is the last place in the world your should
take hints and advice from, most of the problems they speak of there
have been fixed years ago.

Please start instrumenting the TCP code instead of "poking around"
hoping you'll hit the grand jackpot by manipulating some sysctl
setting.

It doesn't help us and it won't help you, start reading and
understanding the TCP code, add debugging printk's, anything to get
more information about this.

And please don't report anything here until you have some solid piece
of debugging information, else I'll just sit here replying and
prodding you along ever so slowly. :(
