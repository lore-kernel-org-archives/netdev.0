From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH RFC 5/5] net: macb: Adjust tx_clk when link speed changes
Date: Tue, 15 Oct 2013 08:34:34 -0700
Message-ID: <bc7eae62-d683-493e-a22a-515e70a0c82b@CO9EHSMHS001.ehs.local>
References: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com>
 <1381795140-10792-6-git-send-email-soren.brinkmann@xilinx.com>
 <525CF4AD.1070304@atmel.com>
 <dd225b7c-ee2a-4747-9a50-55b77a114376@DB9EHSMHS006.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dd225b7c-ee2a-4747-9a50-55b77a114376@DB9EHSMHS006.ehs.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2013 at 09:58:09AM +0200, Michal Simek wrote:
> On 10/15/2013 09:54 AM, Nicolas Ferre wrote:
> > On 15/10/2013 01:59, Soren Brinkmann :
> >> Adjust the ethernet clock according to the negotiated link speed.
> >>
> >> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> >=20
> > I will need more time to study this one.
> >=20
> > Moreover, I will have to add the "tx_clk" to every user of this dri=
ver before switchin to the addition of this clock.
>=20
> As I am reading this patch, Soren just protected this
> case that if this clk is not specified then it is not used.
That is how I sketched things in this patch. But as I said, I'm not
fully convinced this approach fits all or is the best. So, if anybody
has a better approach, let us know.

	S=C3=B6ren
