From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 331/493] ethernet: remove use of __devinitdata
Date: Wed, 21 Nov 2012 12:08:01 +0000
Message-ID: <20121121120801.GL3290@n2100.arm.linux.org.uk>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-331-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	Florian Fainelli <florian@openwrt.org>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	e1000-devel@lists.sourceforge.net
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:47888 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab2KUMIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:08:40 -0500
Content-Disposition: inline
In-Reply-To: <1353349642-3677-331-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is getting painful to review; why couldn't all the changes to one
set of drivers be grouped together?  I'm having to search out the same
drivers I'm responsible for many times in this patch set to do a review,
and it's getting extremely tiresome and probably becoming more probable
that I'll make a mistake.

So I'm going to stop sending acked-by's after this one.

Please consider the workload you put reviewers under next time, thanks.

On Mon, Nov 19, 2012 at 01:24:40PM -0500, Bill Pemberton wrote:
>  drivers/net/ethernet/i825xx/ether1.c              | 2 +-
>  drivers/net/ethernet/seeq/ether3.c                | 2 +-

Not sure if I missed couple are missing (etherh?  am79c961a?)...

But for these two,
Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
