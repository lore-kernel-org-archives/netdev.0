From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [GIT PULL] Marvell Ethernet driver clk support + section
 mismatch fix
Date: Wed, 21 Nov 2012 13:35:45 +0100
Message-ID: <20121121133545.1a45263c@skate>
References: <1353334396-26128-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:39759 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab2KUMf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:35:58 -0500
In-Reply-To: <1353334396-26128-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On Mon, 19 Nov 2012 15:13:14 +0100, Thomas Petazzoni wrote:

>  * One adding clk support. It's not a fix, but I think it's better if
>    we can get the Device Tree binding correct directly in 3.8. This
>    commit basically replaces the clock-frequency DT property by a
>    proper 'clocks' DT property that references a DT clock. If we don't
>    get this in 3.8, we'll have to support the legacy clock-frequency
>    DT property for ever as it will be part of the kernel-to-DT ABI. So
>    it would be nicer to get this patch in for 3.8.
> 
>    The DT patches related to this one are coming into a separate pull
>    request.
> 
>  * The second one fixes a section mismatch warning, so it is certainly
>    important.

Do you agree with those two changes? If so, shall we carry them with
the rest of the mvneta driver through arm-soc with your Acked-by?

Thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
