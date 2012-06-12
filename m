From: Federico Vaga <federico.vaga@gmail.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 12 Jun 2012 16:25:25 +0200
Message-ID: <2105333.GQGP4hKIYU@harkonnen>
References: <4FC135C6.5030206@grandegger.com> <1338816766-7089-2-git-send-email-federico.vaga@gmail.com> <4FCCC077.7000303@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	Alessandro Rubini <rubini@gnudd.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FCCC077.7000303@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +out_free_clock:
> > +	if (!priv->priv)
> 
>            ^^^
> 
> looks fishy

Also c_can_platform.c use priv->priv when it needs to get clk. I can add 
a comment to specify what the statement do.

-- 
Federico Vaga
