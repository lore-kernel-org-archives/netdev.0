From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [Netchannels] Userspace network stack performance.
Date: Thu, 21 Dec 2006 19:08:05 +0300
Message-ID: <20061221160805.GA10845@2ka.mipt.ru>
References: <20061220151245.GA19335@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56129 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422956AbWLUQIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 11:08:23 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061220151245.GA19335@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Userspace network stack over new netchannels performance.

Sending:
	o 128 bytes writing:
		* netchannels: 27-28 MB/sec, 20-30 % CPU usage
		* sockets: 7-8 MB/sec, 80-90 % CPU usage
	o 4096 bytes writing:
		* netchannels: 27-28 MB/sec, 20-30 % CPU usage
		* sockets: 30-31 MB/sec, 30-40 % CPU usage

Receiving:
	o 128 bytes reading:
		* netchannels: 70-71 MB/sec, 80-90 % CPU usage
		* sockets: 24-25 MB/sec, 80-90 % CPU usage
	o 4096 bytes reading:
		* netchannels: 73-74 MB/sec, 80-90 % CPU usage
		* sockets: 79-80 MB/sec, 80-90 % CPU usage

Stack is available from project homepage at
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

-- 
	Evgeniy Polyakov
