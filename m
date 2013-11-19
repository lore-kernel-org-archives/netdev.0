From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Revert "af-packet: Use existing netdev reference
 for bound sockets"
Date: Mon, 18 Nov 2013 20:26:58 -0500 (EST)
Message-ID: <20131118.202658.118112656342762223.davem@davemloft.net>
References: <20131118.130310.1183708218770881544.davem@davemloft.net>
	<528AA531.3000305@redhat.com>
	<CAO7SqHCBRrfq3EfLMzrOa_A4e2tyaqdzTo=V7vE06YVnk5D0iA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, willemb@google.com, phil@nwl.cc,
	edumazet@google.com, netdev@vger.kernel.org,
	greearb@candelatech.com
To: noureddine@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858Ab3KSB1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 20:27:02 -0500
In-Reply-To: <CAO7SqHCBRrfq3EfLMzrOa_A4e2tyaqdzTo=V7vE06YVnk5D0iA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@aristanetworks.com>
Date: Mon, 18 Nov 2013 16:17:02 -0800

> Thanks for looking into this. It seems to me that just using a flag
> won't help in avoiding the race condition since packet_notifier can
> still run after the flag check.

The bind_lock syncronizes everything.
