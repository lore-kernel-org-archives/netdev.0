From: Peter Tyser <ptyser@xes-inc.com>
Subject: Re: [PATCH] sky2: RX lockup fix
Date: Thu, 06 Dec 2007 10:14:57 -0600
Message-ID: <1196957697.24978.24.camel@localhost.localdomain>
References: <1196880663.2816.149.camel@localhost.localdomain>
	 <20071205164058.157275a9@shemminger-laptop>
	 <1196900326.21996.1.camel@localhost.localdomain>
	 <20071205225249.0f46672c@shemminger-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:39794 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011AbXLFQRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 11:17:46 -0500
In-Reply-To: <20071205225249.0f46672c@shemminger-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have ways to generate errors, so I'll check

Thanks Stephen.  We didn't spend a lot of time characterizing the issue,
but our test setup had two blades, each with an 88E8062.  Our test
software pumped UDP and TCP traffic of varying packet sizes between the
blades in both directions (including  jumbo frames - we increased the
MTU of the interfaces to 9000).  The issue could generally be brought
out in about 15 minutes and almost always within an hour.

If you'd like any additional details on the test setup or would like me
to try something on my end, let me know.



