From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: What is lock_sock() before skb_free_datagram() for?
Date: Sat, 18 Apr 2009 17:04:01 +0900
Message-ID: <200904181704.FDC21361.FQLOFHOOSVFtMJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:58742 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848AbZDRIEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2009 04:04:05 -0400
Received: from CLAMP (p1194-ipbf6009marunouchi.tokyo.ocn.ne.jp [114.145.72.194])
	by smtp.wine.ocn.ne.jp (Postfix) with ESMTP id 9671A3172
	for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 17:04:03 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

udp_recvmsg() and udpv6_recvmsg() call skb_free_datagram() with 
lock_sock().
But raw_recvmsg() and rawv6_recvmsg() call skb_free_datagram() 
without
lock_sock().
Is it OK?
