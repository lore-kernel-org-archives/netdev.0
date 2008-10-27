From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: broken rtl8139 and dropped frames decreasing?
Date: Mon, 27 Oct 2008 12:50:59 +0000
Message-ID: <1225111859.3018.4.camel@achroite>
References: <49057814.2000403@caiway.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Evert van Grootheest <j.e.van.grootheest@caiway.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:56925 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751021AbYJ0MvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 08:51:05 -0400
In-Reply-To: <49057814.2000403@caiway.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-27 at 09:13 +0100, Jan Evert van Grootheest wrote:
> Hi,
> 
> I've got this old computer of a friend (to rescue files and put Ubuntu 
> on it (-: ).
> And there's something strange going on in the network stack somewhere.
> 
> I've booted it using an Ubuntu Hardy live CD (i.e. 2.6.24-something kernel).
> There's a rtl8139 card in it that uses the 8139too module. But something 
> is not right with the hardware. Dmesg is full of reports with TX ring 
> pointers when I plug the cable and try to ping something.
> 
> The interesting thing is that 'ifconfig eth0' shows dropped RX packets. 
> But each invocation shows one LESS dropped packet! It's never been above 
> zero (that I have seen). The counter currently stands at 4294967260 
> (i.e. -36).
[...]

That might indicate that the RxMissed register is not implemented on
this version of the chip.  That could result in the driver adding a
value of all-1s (effectively -1) to the rx_missed_errors statistic.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

