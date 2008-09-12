From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: ifconfig: page allocation failure. order:2, mode:0x20 while enabling Jumbo frame
Date: Fri, 12 Sep 2008 09:59:03 +0400
Message-ID: <20080912055903.GA27431@2ka.mipt.ru>
References: <473F5AEA857EA644A9AD7693EBA8D9A203449248@CORPUSMX20B.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kandukuru_Suresh@emc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:53368 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750701AbYILF7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 01:59:39 -0400
Content-Disposition: inline
In-Reply-To: <473F5AEA857EA644A9AD7693EBA8D9A203449248@CORPUSMX20B.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Sep 11, 2008 at 04:42:22PM -0400, Kandukuru_Suresh@emc.com (Kandukuru_Suresh@emc.com) wrote:
>  On my Nas device (Linux kernel 2.6.22.7)  when I try enable to jumbo
> frame the following error is coming. I  did not find enough information
> from the net. So I  am mailing this. Please guide me  what is happening
> here and How to resolve this error?

Device or driver does not support multiple page network buffers, so it
tries to allocate huge buffer (4 pages) for each packet.
I can not find eth_rx_fill() function in a recent kernel, so maybe
driver was rewritten after .22 release and now supports per-page split
of the packet, so it will happily live with jumbo frames.

-- 
	Evgeniy Polyakov
