From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Wed, 12 Dec 2012 14:23:27 -0500 (EST)
Message-ID: <20121212.142327.2290797438095968580.davem@davemloft.net>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, daniel.borkmann@tik.ee.ethz.ch,
	xemul@parallels.com, ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul.Chavent@onera.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab2LLTXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 14:23:33 -0500
In-Reply-To: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You're changing the code that handles sendmsg() and then wondering why
a recvmsg() call doesn't provide a timestamp.
