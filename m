From: Darek Marcinkiewicz <reksio@newterm.pl>
Subject: Re: [PATCH v4 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Fri, 2 May 2014 20:24:37 +0200
Message-ID: <20140502182437.GC1156@newterm.pl>
References: <20140501062047.GA1156@newterm.pl>
 <20140501155331.GA6523@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140501155331.GA6523@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello. Thank you for your comments.

On Thu, May 01, 2014 at 05:53:31PM +0200, Francois Romieu wrote:
> Darek Marcinkiewicz <reksio@newterm.pl> :
> [changes]
> 
[...]
> 
> > +
> > +struct bh_priv {
> 
> Nit: it would be nice to avoid "_bh_" as it is already used in a set of
> common kernel functions.
> 
I renamed bh to bhf and as result also changed the driver name - to ec_bhf.
> [...]
> > +	u8 *tx_put;
> > +	u8 *tx_get;
> 
> It's part u8 and part tx_header.
> 
> You may consider using a struct that adds an extra 'u8 data[0]' at
> the end of the struct tx_header.
> 
> skb_copy_and_csum_dev in the xmit path rings a bell but the DMA FIFO
> zone handling could imho save some pointer arithmetic and turn a bit
> more literate.
> 
I did some rework of descriptors handling and they are now kept in
a list so no pointer arithmetic at all.

As for the rest of your comments - all of them are incorporated
in next revision of the patch.

Thank you.

-- 
DM

-- 
DM
