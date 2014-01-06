From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Mon, 06 Jan 2014 10:07:00 +0100
Message-ID: <1388999220.5891.3.camel@jlt4.sipsolutions.net>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
	  <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
	  <1388429761.4410.1.camel@jlt4.sipsolutions.net>
	  <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
	  <1388438724.4573.2.camel@jlt4.sipsolutions.net>
	  <20131230215701.GA4938@khazad-dum.debian.net>
	  <1388445188.18164.0.camel@jlt4.sipsolutions.net>
	  <1388445422.26796.38.camel@joe-AO722>
	  <alpine.DEB.2.10.1401060947550.2079@hadrien>
	 <1388998750.5808.43.camel@joe-AO722>
	 <alpine.DEB.2.10.1401061001340.2079@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	kernel-janitors@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1401061001340.2079@hadrien>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-06 at 10:04 +0100, Julia Lawall wrote:

> OK, the question was expressed badly.  Is there any way to use the value
> to trigger an action at build time?  The only way I kow to trigger an
> action is with #error, but #error is processed by cpp, which doesn't know
> about the size of types.

That's exactly BUILD_BUG_ON(), I believe.

johannes


