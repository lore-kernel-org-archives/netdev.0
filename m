From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] consolidate duplicate code is
 skb_checksum_setup() helpers
Date: Thu, 27 Feb 2014 18:18:42 -0500 (EST)
Message-ID: <20140227.181842.277867476845635582.davem@davemloft.net>
References: <9AAE0902D5BC7E449B7C8E4E778ABCD025D4FD@AMSPEX01CL01.citrite.net>
	<530F3B8F020000780011FD33@nat28.tlf.novell.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD025D6D2@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBeulich@suse.com, edumazet@google.com, netdev@vger.kernel.org
To: Paul.Durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbaB0XTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 18:19:30 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD025D6D2@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <Paul.Durrant@citrix.com>
Date: Thu, 27 Feb 2014 12:39:01 +0000

> I don't know off the top of my head - I'd have to go look. My hunch
> is that TCP options are essentially independent of IP
> version. Anyway, the header is limited to 60 bytes max due to the 4
> bit width of the header length field so you may as well just use
> that.

Regardless, the MAX_IP_HDR_LEN macro that was being used in these
routines makes the intent clear, that the TCP options need to be
encompassed.

And this new consolidated code does not do that.
