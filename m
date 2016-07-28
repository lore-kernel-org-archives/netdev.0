From: ashwanth@codeaurora.org
Subject: Uncreachable default lo route in table 0
Date: Thu, 28 Jul 2016 13:31:46 +0530
Message-ID: <1c8b25ef7ed1c8a79a5ad932e802ea65@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <roszenrami@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55794 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbcG1IBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 04:01:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On an Android device(using 3.18 kernel version) we see multiple entries 
as the following added to the route table 0(unspec) by kernel. We 
noticed that this typically happens when we toggle WIFI repeatedly. The 
problem we see is that under such stress test, the table 0 gets filled 
with these entries(4096) and after that no further routes can get added 
leading to unstability.

unreachable default dev lo table 0 proto kernel metric 4294967295 error 
-101

Can you please let us know why does this route get added for lo device 
and when is this supposed to be flushed out?
