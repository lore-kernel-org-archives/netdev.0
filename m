From: Thomas Graf <tgraf@infradead.org>
Subject: Re: the future of ethtool
Date: Tue, 16 Nov 2010 01:17:46 -0500
Message-ID: <20101116061746.GC24292@canuck.infradead.org>
References: <1289857936.2586.51.camel@bwh-desktop>
 <4CE1B8FD.3000007@garzik.org>
 <20101115233335.GB24292@canuck.infradead.org>
 <20101115.180225.189678628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, bhutchings@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:46159 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529Ab0KPGRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 01:17:52 -0500
Content-Disposition: inline
In-Reply-To: <20101115.180225.189678628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 15, 2010 at 06:02:25PM -0800, David Miller wrote:
> It isn't sufficient.  You can still get into unwindable failures.
> 
> Earlier operations can consume fixed resources like TCAM filter
> slots or rx/tx queues, making a subsequent operation in the
> sequence fail.
> 
> A validate/commit scheme cannot detect this effectively.

I agree, there are many more scenarios where it would not work
reliably. It would have ensured that all provided values are
within range boundries and that all requested operations are in
fact supported. Since I have disregarded the idea, I does not
matter much anymore.
