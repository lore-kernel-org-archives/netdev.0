From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: baycom_ser_fdx - fixed under 2.6
Date: Tue, 22 Jul 2008 13:08:46 +0100
Message-ID: <20080722120846.GA26093@linux-mips.org>
References: <alpine.DEB.1.10.0807191042050.21295@tombstone.paradise.gen.nz> <4885A8F6.7090109@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Robb <ender@paradise.gen.nz>, linux-hams@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pidoux <f6bvp@free.fr>, Jeff Garzik <jeff@garzik.org>,
	stable@kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4885A8F6.7090109@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 22, 2008 at 11:31:34AM +0200, Pidoux wrote:

> This is a trivial but very important bug fix. Thanks David.
> It was probably not submitted to the right destination and thus never applied.
>
> This bug may have discouraged more than one radioamateur wishing to experiment baycom style modems under Linux.
> Fortunately you have done a very good historical search.
>
> I rebuilt the patch against 2.6.26 kernel (the only source I have here on my laptop at my remote location during vacation).
>
> I Cc: to David Miller and Ralf Baechle DL5RB maintainers of Linux net devices drivers and Linux AX25 drivers, respectively.

Correct, the CRC should go at the end of the frame, not corrupt the first
header bytes.  So this one should also go into -stable.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
