From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch 2/2] qlcnic: using too much stack
Date: Mon, 9 Aug 2010 20:42:54 +0200
Message-ID: <20100809184254.GJ9031@bicker>
References: <20100809103727.GH9031@bicker> <0081C370-65E2-434F-BBC6-C688F6F39750@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	Linux Driver <Linux-Driver@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:57114 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688Ab0HISnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 14:43:47 -0400
Content-Disposition: inline
In-Reply-To: <0081C370-65E2-434F-BBC6-C688F6F39750@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 09, 2010 at 09:46:32AM -0700, Anirban Chakraborty wrote:
> 
> It looks fine except that I'd use kzalloc instead of kcalloc above.
> 

It's no problem to do that, and I'm already respinning the patches but 
I'm confused.  It looks like pci_info gets initialized correctly.  What
am I missing?

regards,
dan carpenter

> thanks,
> -Anirban
