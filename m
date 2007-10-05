From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-2.6.24] s2io: sparse warnings fix
Date: Fri, 05 Oct 2007 13:51:51 -0400
Message-ID: <470679B7.2060901@pobox.com>
References: <20071005090725.09a80bc7@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	Raapur Santosh <santosh.rastapur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34438 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752609AbXJERwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 13:52:00 -0400
In-Reply-To: <20071005090725.09a80bc7@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix warnings from sparse checker about shadowed definition and improperly
> formatted ethtool_strings.
> 
> I chose to change module parameter rather than uglify the code by changing
> the variable name.

Changing the name of existing module parameters can potentially 
introduce breakage in the field.

Additionally, we have module_param_named() to account for this sort of 
thing, where the module parameter name differs from the internal 
variable name.

The rest looks OK.

Please resend, potentially moving the module parameter change(s) into a 
separate patch.

