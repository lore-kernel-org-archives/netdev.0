From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 12:45:46 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FAA275CBE@EAPEX1MAIL1.st.com>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au>
	<D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
 <20120619.213703.513466167861199217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"federico.vaga@gmail.com" <federico.vaga@gmail.com>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120619.213703.513466167861199217.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, June 20, 2012 10:07 AM
> To: Bhupesh SHARMA
> Cc: sfr@canb.auug.org.au; netdev@vger.kernel.org; linux-
> next@vger.kernel.org; linux-kernel@vger.kernel.org;
> federico.vaga@gmail.com; Giancarlo ASNAGHI; wg@grandegger.com;
> mkl@pengutronix.de
> Subject: Re: linux-next: build failure after merge of the net-next tree
> 
> From: Bhupesh SHARMA <bhupesh.sharma@st.com>
> Date: Wed, 20 Jun 2012 12:27:11 +0800
> 
> > clk_get/clk_put* variants are usually used by ARM platforms.
> > Protecting their calls under macro 'CONFIG_HAVE_CLK' should solve the
> problem.
> 
> No, we don't pepper foo.c files with crappy ifdefs.

So, whether adding a check in Kconfig for HAVE_CLK be a proper solution ?
But that will limit the compilation of this driver for only platforms which are ARM based.

One may need to support this driver on x86 like platforms also..

Regards,
Bhupesh
