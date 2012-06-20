From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 19 Jun 2012 21:47:59 -0700 (PDT)
Message-ID: <20120619.214759.2265041580160751452.davem@davemloft.net>
References: <D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
	<20120619.213703.513466167861199217.davem@davemloft.net>
	<D5ECB3C7A6F99444980976A8C6D896384FAA275CBE@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	federico.vaga@gmail.com, giancarlo.asnaghi@st.com,
	wg@grandegger.com, mkl@pengutronix.de
To: bhupesh.sharma@st.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384FAA275CBE@EAPEX1MAIL1.st.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Date: Wed, 20 Jun 2012 12:45:46 +0800

> So, whether adding a check in Kconfig for HAVE_CLK be a proper
> solution ?  But that will limit the compilation of this driver for
> only platforms which are ARM based.
> 
> One may need to support this driver on x86 like platforms also..

Then x86 will need to provide clock operations, or there needs to
be dummy ones for such platforms.

This isn't rocket science.
