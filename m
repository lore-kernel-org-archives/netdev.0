From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Puzzling driver problem
Date: Tue, 12 May 2009 13:32:19 +0100
Message-ID: <1242131539.3935.17.camel@deadeye>
References: <4A08F777.6040605@dlasys.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhlii@dlasys.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50153 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754433AbZELMcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 08:32:23 -0400
In-Reply-To: <4A08F777.6040605@dlasys.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-05-12 at 00:13 -0400, David H. Lynch Jr. wrote:
> I am working on a driver for the Xilinx Local Link Fifo Temac.
>     It is based on an earlier driver for very similar hardware that uses
> a scatter gather DMA engine rather than a FIFO.
>     95% of the code is common.
>     The FIFO code is also tested independently in a bootloader and works
> fine there.
> 
>     The problem I am having is that after the driver and linux load.
>     HTTP requests to the busy box web server hang after just a few HTTP
> packets.
>    
>     Many other protocols seem to be working just fine. I can send
> thousands of pings and get responses,
>     I can SSH to the embedded linux running the driver.
>     Using a packet sniffer (wireshark) aside from the HTTP stalling,
> nothing looks extrodinary.
>     Other packets are getting through and being replied
[...]

Is it possible that you are setting the maximum frame length
incorrectly?  HTTP is likely to use maximum-length frames for responses
whereas ping, SSH (aside from file transfer) and TFTP will use smaller
frames.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
