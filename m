From: julius <commercials22@yahoo.com>
Subject: tc filter ouput, no filter hits?
Date: Sat, 29 Dec 2012 05:46:17 -0800 (PST)
Message-ID: <1356788777.97050.YahooMailNeo@web165006.mail.bf1.yahoo.com>
Reply-To: julius <commercials22@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm17.bullet.mail.bf1.yahoo.com ([98.139.212.176]:34922 "EHLO
	nm17.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752268Ab2L2NqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 08:46:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

ive seen some examples where the output from:
tc -s filter show dev ifb0 parent 1: 
shows a filter hit count, like the output shown below:

filter protocol ip pref 1 u32
filter protocol ip pref 1 u32 fh 800: ht divisor 1
filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 
1:1  (rule hit 2 success 0)



however in my openwrt 12.09 and on my ubuntu machine i dont see the part in the paranthese, why is that?

ubuntu:
iproute (20120521-3ubuntu1)
3.2.0-23-generic #36-Ubuntu


greets
