From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 12:35:40 +0100
Message-ID: <20120620113539.GA928@sirena.org.uk>
References: <D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
 <20120619.213703.513466167861199217.davem@davemloft.net>
 <D5ECB3C7A6F99444980976A8C6D896384FAA275CBE@EAPEX1MAIL1.st.com>
 <20120619.214759.2265041580160751452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhupesh.sharma@st.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, federico.vaga@gmail.com,
	giancarlo.asnaghi@st.com, wg@grandegger.com, mkl@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120619.214759.2265041580160751452.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 19, 2012 at 09:47:59PM -0700, David Miller wrote:
> From: Bhupesh SHARMA <bhupesh.sharma@st.com>

> > So, whether adding a check in Kconfig for HAVE_CLK be a proper
> > solution ?  But that will limit the compilation of this driver for
> > only platforms which are ARM based.

> > One may need to support this driver on x86 like platforms also..

> Then x86 will need to provide clock operations, or there needs to
> be dummy ones for such platforms.

Not directly germane but I've been sending patches for this to the x86
guys for a little while though they're doing a /dev/null impression.

> This isn't rocket science.

The other option is that the clock API stubs itself out when not enabled
which is going into mainline (not sure quite where it is at the minute).

These sort of per-arch APIs should be a legacy thing, hopefully we'll
manage to squash them at some point and we should certainly work to
avoid introducing new ones.
