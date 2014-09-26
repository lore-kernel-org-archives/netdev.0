From: Laurent CARON <lcaron@lncsa.com>
Subject: Regarding bug 82471
Date: Fri, 26 Sep 2014 18:35:34 +0200
Message-ID: <542595D6.6040904@lncsa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-siege-002.lncsa.com ([46.21.113.22]:47444 "EHLO
	smtp-out-siege-002.lncsa.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755344AbaIZQpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 12:45:07 -0400
Received: from [10.225.0.195] (donald.lncsa.com [10.225.0.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: lcaron)
	by smtp-out-siege-002.lncsa.com (Postfix) with ESMTPSA id 9E41EC067B
	for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 18:35:31 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been biten by : https://bugzilla.kernel.org/show_bug.cgi?id=82471 
today.

I tried various kernels from 3.2.0 to 3.16.3

The last unaffected kernel according to my tests is 3.14 (didn't yet try 
3.15).

Please see logs when (on 3.16.2)
1/ using iptables
2/ having some traffic (even light) going through

http://pastebin.com/JWkFu2w2

My network config is the following:

a bond interface consisting of 2 10Gb ports (intel ixgbe / X520-SR2) on 
top of which I use 2 vlans.

Thanks for your help,

Laurent
