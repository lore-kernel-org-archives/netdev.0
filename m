From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: Re: [PATCH updated] net: add ability to clear per-interface	network
Date: Sat, 17 May 2008 11:30:39 +0930
Message-ID: <20080517113039.b0aaf932.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from levanto.mail.adnap.net.au ([203.6.132.83]:3213 "EHLO
	levanto.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbYEQCz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 22:55:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(applogies for not preserving list details, not subscribed)

">>Syntax:
>>  echo 'net clear-stats ifdev' > /proc/net/dev
>>Where "ifdev" is the device name you wish to clear.

I don't wish to suggest I don't like the change - I've used similar 
features on "other oses" in the past, but when something like this has 
come-up in the past, haven't there been concerns about MIBs and SNMP and 
whatnot?

rick jones"

I like the way cisco do this. You can clear the CLI visible interface
counters in the CLI, and the snmp counters aren't cleared, so obviously
they're maintaining two sets of counters.

Clearing the interface counters can be very useful when
troubleshooting, as you can use it to get a feel for error rates per
second etc.

Should two sets of counters be implemented in Linux, the
improvement over the cisco method I'd suggest is an ability to
resynchronise the user visible counters back to the snmp values, should
you have cleared the user visible ones.

Regards,
Mark.
