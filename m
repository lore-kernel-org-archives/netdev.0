From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH 00/17] ATM fixes for pppoatm/br2684
Date: Fri, 30 Nov 2012 11:44:11 +0100
Message-ID: <20121130104411.GA16410@shrek.podlesie.net>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shrek-wifi.podlesie.net ([93.179.225.50]:46530 "EHLO
	shrek.podlesie.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab2K3KoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 05:44:14 -0500
Content-Disposition: inline
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2012 at 12:35:19AM +0000, David Woodhouse wrote:
> This is the result of pulling on the thread started by Krzysztof Mazur's
> original patch 'pppoatm: don't send frames to destroyed vcc'.
> 
> Various problems in the pppoatm and br2684 code are solved, some of which
> were easily triggered and would panic the kernel.
> 
> The patch series can be pulled from
> 	git://git.infradead.org/users/dwmw2/atm.git
> or viewed at 
> 	http://git.infradead.org/users/dwmw2/atm.git
> 
> DaveM, please wait for an ack from Krzysztof and Chas before pulling this.

looks good to me, except "pppoatm: drop frames to not-ready vcc"
that needs updated commit message update after we drop "1/7".

Thanks,

Krzysiek
