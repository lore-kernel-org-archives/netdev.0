From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RTL8169 driver no longer functioning with 8111b
Date: Wed, 14 May 2008 23:37:10 +0200
Message-ID: <20080514213710.GA8465@electric-eye.fr.zoreil.com>
References: <4828D529.3060201@gtf.org> <20080513205140.GA11808@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0805131821500.2988@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ack <ackman@gtf.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39336 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750899AbYENV7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 17:59:51 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805131821500.2988@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack <ackman@gtf.org> :
[...]
> I'd not had this problem on reboot any in the past, it's always been 
> autoneg and ethtool was reporting as expected for that option. Very 
> strange.  Thanks for wasting your time though.  Not sure what would need to 
> be done for the driver for this as I'm not really sure how it got to the 
> state it was in just by that reboot.

Please send the XID line and the output of lspci w/o the H1 option.

You almost surely hit a real link management bug.

-- 
Ueimor
