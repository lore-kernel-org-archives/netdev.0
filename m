From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH net-next 6/8] dsa: Allow core and drivers to be built as
 modules
Date: Sun, 27 Nov 2011 20:19:55 +0100
Message-ID: <20111127191955.GU795@wantstofly.org>
References: <1322267572.2839.381.camel@deadeye>
 <1322267918.2839.388.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:65488 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab1K0TT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 14:19:57 -0500
Content-Disposition: inline
In-Reply-To: <1322267918.2839.388.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2011 at 12:38:38AM +0000, Ben Hutchings wrote:

> Change the kconfig types to tristate and adjust the condition for
> declaring net_device::dsa_ptr to allow for this.
> 
> Adjust the makefile so that if NET_DSA_MV88E6123_61_65=y and
> NET_DSA_MV88E6131=m or vice versa then both drivers are built-in.  We
> could leave these options as bool and make NET_DSA_MV88E6XXX a
> user-selected option, but that would break existing configurations.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Thanks for the patches!

(While you're at it -- the switch chip drivers in net/dsa/ still
ought to be moved to drivers/net/dsa/ or so -- feel like whipping up
a patch for that?)
