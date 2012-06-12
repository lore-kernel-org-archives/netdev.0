From: Federico Vaga <federico.vaga@gmail.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 12 Jun 2012 16:53:10 +0200
Message-ID: <2787339.ybXZAN0ltf@harkonnen>
References: <4FC135C6.5030206@grandegger.com> <2105333.GQGP4hKIYU@harkonnen> <4FD75648.7060702@pengutronix.de>
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
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4FD75648.7060702@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > +out_free_clock:
> > +	if (!priv->priv)
> > +		clk_put(priv->priv);
> 
> Why do you call clk_put on priv->priv, if priv->priv is NULL?

Right!

if(priv->priv)
    clk_put(priv->priv);

-- 
Federico Vaga
