From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] fix two more udp pull header issues
Date: Wed, 13 Apr 2016 22:25:54 -0400 (EDT)
Message-ID: <20160413.222554.1942915187151383805.davem@davemloft.net>
References: <1460067179-67789-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	samanthakumar@google.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbcDNC0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 22:26:01 -0400
In-Reply-To: <1460067179-67789-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu,  7 Apr 2016 18:12:57 -0400

> Follow up patches to the fixes to RxRPC and SunRPC. A scan of the
> code showed two other interfaces that expect UDP packets to have
> a udphdr when queued: read packet length with ioctl SIOCINQ and
> receive payload checksum with socket option IP_CHECKSUM.

As we are seeing, lots of places depend upon the old way of queueing
up UDP frames. :-/

Applied, thanks for mopping all of this up.
