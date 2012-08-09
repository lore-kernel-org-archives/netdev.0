From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCHv2 1/4] modem_shm: Add Modem Access Framework
Date: Thu, 9 Aug 2012 12:38:55 +0100
Message-ID: <20120809123855.1ba0fffb@pyramind.ukuu.org.uk>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
	<1344322471-3640-2-git-send-email-arun.murthy@stericsson.com>
	<20120807183809.GC26990@kroah.com>
	<F45880696056844FA6A73F415B568C695B0E796A03@EXDCVYMBSTM006.EQ1STM.local>
	<20120808133748.GA14459@kroah.com>
	<F45880696056844FA6A73F415B568C695B0E797048@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Sjur BRENDELAND <sjur.brandeland@stericsson.com>
To: Arun MURTHY <arun.murthy@stericsson.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <F45880696056844FA6A73F415B568C695B0E797048@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Maybe tty can do this, but want to have all modem related  separately.
> There are many such hardware and many drivers coming up in near future.

tty can't do all this. We have similar things with stuff like CAIF. Modem
has gone from pretending to be a serial port (tty) to appearing as a
smart multi-function controller.

tty is the right way to expose any actual 'AT' modem emulation type
stuff, but it's not really relevant for most uses of a modern 3G/4G modem
- also also too slow !

Alan
