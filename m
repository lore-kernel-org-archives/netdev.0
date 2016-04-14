From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] sctp: delay calls to sk_data_ready() as much as
 possible
Date: Wed, 13 Apr 2016 23:05:32 -0400 (EDT)
Message-ID: <20160413.230532.676746231426161126.davem@davemloft.net>
References: <cover.1460144373.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, David.Laight@ACULAB.COM,
	jkbs@redhat.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbcDNDFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 23:05:35 -0400
In-Reply-To: <cover.1460144373.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri,  8 Apr 2016 16:41:26 -0300

> 1st patch is a preparation for the 2nd. The idea is to not call
> ->sk_data_ready() for every data chunk processed while processing
> packets but only once before releasing the socket.
> 
> v2: patchset re-checked, small changelog fixes
> v3: on patch 2, make use of local vars to make it more readable

Applied to net-next, but isn't this reduced overhead coming at the
expense of latency?  What if that lower latency is important to the
application and/or consumer?
