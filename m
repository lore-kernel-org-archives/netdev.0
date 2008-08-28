From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: 2.6.27-rc ... iwl3945 regression?
Date: Fri, 29 Aug 2008 00:03:18 +0200
Message-ID: <20080829000318.53e2212a@siona.skinnemoen.net>
References: <200808131735.42451.david-b@pacbell.net>
 <20080828164134.1cd3bb12@hskinnemo-gx745.norway.atmel.com>
 <200808280948.07358.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpeu1.atmel.com ([195.65.72.27]:54796 "EHLO bagnes.atmel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131AbYH1WDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 18:03:18 -0400
In-Reply-To: <200808280948.07358.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Aug 2008 09:48:07 -0700
David Brownell <david-b@pacbell.net> wrote:

> > FWIW, I'm seeing the same thing with -rc4 and the b43 driver, so
> > it's probably not a regression in iwl3945. I guess it could be
> > something in mac80211?  
> 
> It was separately suggested that I ignore the advice about no
> software needing it, and enable CONFIG_WIRELESS_EXT_SYSFS ...
> that did the trick for me.

That did the trick for me too...great!

> That Kconfig helptext needs updating so it's not completely wrong.

Yeah, NetworkManager definitely counts as "any".

Haavard
