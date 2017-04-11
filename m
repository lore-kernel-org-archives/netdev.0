From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Tue, 11 Apr 2017 21:13:45 +1000
Message-ID: <1491909225.4166.248.camel@kernel.crashing.org>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
         <20170411010436.23290-2-benh@kernel.crashing.org>
         <7d0f6000-3be5-ed70-49d3-3a3916dd79ff@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49712 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754668AbdDKLOP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:14:15 -0400
In-Reply-To: <7d0f6000-3be5-ed70-49d3-3a3916dd79ff@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 13:57 +0300, Sergei Shtylyov wrote:
>     Need {} here as well since the 1st branch has it -- see 
> Documentation/process/coding-style.rst (the end of the section 3).

Adding {} in that specific statements just makes things more
cluttered and less readable.

I can find a ton of examples of 

	if (...) {
		multi lines
		...
	} else if (...)
		single_line()

In existing kernel code.

I'll fix it in a next spin if Dave wants it that way but otherwise
I'm keen to leave it as it is.

Ben.
