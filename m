From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH v2] ethtool : Allow ethtool to set interface in loopback
 mode.
Date: Fri, 3 Dec 2010 17:03:33 +0100
Message-ID: <20101203160333.GA235120@jupiter.n2.diac24.net>
References: <AANLkTikxHDksqrvG4uNJ8JVY5AJgcftQy2F4ihJBV=TE@mail.gmail.com>
 <1291299660.3259.5.camel@bwh-desktop>
 <AANLkTi=GygGKnuSZmWecmGejDjzLx2uaHuk+DroVfHDy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:36987 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408Ab0LCQDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Dec 2010 11:03:41 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=GygGKnuSZmWecmGejDjzLx2uaHuk+DroVfHDy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 02, 2010 at 02:35:51PM -0800, Mahesh Bandewar wrote:
> This patch adds -L command-line option to switch loopback mode on/off
> and -l option to display current loopback mode on a specified interface.
[...]
> +.A1 on off
> +Switches loopback mode
> +.B on
> +or
> +.B off

What about devices that support different kinds of loopback, like MAC
loopback & PHY loopback? (No idea if we have kernel support for this
either...)


-David

