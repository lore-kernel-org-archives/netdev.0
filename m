From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Tue, 13 Jan 2009 09:53:23 +0000
Message-ID: <20090113095323.GB4808@ff.dom.local>
References: <496C198A.4060502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:24393 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755003AbZAMJx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 04:53:29 -0500
Received: by ey-out-2122.google.com with SMTP id 22so1421672eye.37
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 01:53:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <496C198A.4060502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-01-2009 05:33, Patrick McHardy wrote:
...
> Its odd that HZ=1000 solved the problem despite HR timers being active.
> Are you sure they're actually enabled? You should see something like
> this in the ringbuffer:

If packets are received in netif_rx_action() for ~2 jiffies why is it
odd they will be xmitted differently after changing HZ?

Jarek P.
