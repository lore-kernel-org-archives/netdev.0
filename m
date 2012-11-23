From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH v2] kvaser_usb: fix "dma on the stack" errors
Date: Fri, 23 Nov 2012 15:16:00 +0100
Message-ID: <20121123141600.GA27562@hposo>
References: <20121123134027.GA32098@hposo>
 <1353678883-23136-1-git-send-email-olivier@sobrie.be>
 <50AF8348.6080701@pengutronix.de>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-can@vger.kernel.org, Wolfgang Grandegge <wg@grandegger.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50AF8348.6080701@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2012 at 03:08:08PM +0100, Marc Kleine-Budde wrote:
> On 11/23/2012 02:54 PM, Olivier Sobrie wrote:
> > The dma buffer given to usb_bulk_msg() must be allocated and not on
> > the stack.
> > See Documentation/DMA-API-HOWTO.txt section "What memory is DMA'able?"
> > 
> > Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
> 
> Thanks, I've squashed it into the original patch and pushed to
> linux-can-next/for-davem

Ok thanks.
Have a good week-end,

Olivier

> 
> Marc
> 
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 



-- 
Olivier
