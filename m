From: Krzysztof Kolasa <kkolasa@winsoft.pl>
Subject: something is wrong in commit 971f10eca1 - tcp: better
 TCP_SKB_CB layout to reduce cache line misses
Date: Sun, 12 Oct 2014 19:11:49 +0200
Message-ID: <543AB655.6060603@winsoft.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: edumazet@gmail.com, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps01.winsoft.pl ([5.133.9.51]:57162 "EHLO vps01.winsoft.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbaJLRWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2014 13:22:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit is the result of bisect my problem with window decoration in 
gnome shell ( button, icons, colors etc.)

after revert this commit I don't have any problem with themes windows

a little impossible, commit to the network and affect the graphics might 
be a problem with the allocation and release of memory

my system: 64bit Ubuntu 12.04.5 LTS, kernel next

latest AMD fglrx driver 14.301 ( problem tested and exist in 14.200 also )

Regards,

Krzysztof
