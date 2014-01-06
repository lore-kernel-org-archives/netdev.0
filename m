From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Mon, 06 Jan 2014 00:59:10 -0800
Message-ID: <1388998750.5808.43.camel@joe-AO722>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
	 <1388429761.4410.1.camel@jlt4.sipsolutions.net>
	 <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
	 <1388438724.4573.2.camel@jlt4.sipsolutions.net>
	 <20131230215701.GA4938@khazad-dum.debian.net>
	 <1388445188.18164.0.camel@jlt4.sipsolutions.net>
	 <1388445422.26796.38.camel@joe-AO722>
	 <alpine.DEB.2.10.1401060947550.2079@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	kernel-janitors@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1401060947550.2079@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-06 at 09:48 +0100, Julia Lawall wrote:
> Is there any way to get sizeof evaluated at build time?

I'm confused a bit by what you want to accomplish.

Except for variable length arrays, isn't sizeof always
evaluated at build time?

6.5.3.4 The sizeof operator
Constraints
[]
2 The sizeof operator yields the size (in bytes) of its operand, which may be an
expression or the parenthesized name of a type. The size is determined from the type of
the operand. The result is an integer. If the type of the operand is a variable length array
type, the operand is evaluated; otherwise, the operand is not evaluated and the result is an
integer constant.
