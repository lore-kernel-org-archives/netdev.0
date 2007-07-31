From: jamal <hadi@cyberus.ca>
Subject: fscked clock sources revisited
Date: Mon, 30 Jul 2007 21:10:39 -0400
Message-ID: <1185844239.5162.17.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Robert.Olsson@data.slu.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:38734 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939430AbXGaBK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 21:10:57 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1506957wxd
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 18:10:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

I have posted this before but got no good response and i havent had time
to chase it. 
While doing some batching tests with pktgen and then with a simple
client server app with udp, it does appear that the clock source used
matters. Here are some basic runs with plain vanilla 2.6.22-rc4 runs
with udp. There are five runs per clock source and each result is in
Mbps.

acpi_pm: 108, 110, 111,  91, 108
tsc:     143, 108, 161, 129, 108
jiffies: 132, 138, 132, 146, 150

jiffies produces better results than tsc which produces better results
than acpi_pm. 

Second issue: I cant consistently get two reboots to always boot with
the same clock source.

Any ideas whats going on here? I havent tried with latest tree.

PS:- These results are very easy to validate with iperf or netperf.

cheers,
jamal

