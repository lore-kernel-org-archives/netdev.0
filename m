From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 19 Jun 2012 21:37:03 -0700 (PDT)
Message-ID: <20120619.213703.513466167861199217.davem@davemloft.net>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au>
	<D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	federico.vaga@gmail.com, giancarlo.asnaghi@st.com,
	wg@grandegger.com, mkl@pengutronix.de
To: bhupesh.sharma@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Date: Wed, 20 Jun 2012 12:27:11 +0800

> clk_get/clk_put* variants are usually used by ARM platforms.
> Protecting their calls under macro 'CONFIG_HAVE_CLK' should solve the problem.

No, we don't pepper foo.c files with crappy ifdefs.
