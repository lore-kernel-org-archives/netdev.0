From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Fix e1000e with Intel 82572EI that has no hardware
 timestamp support
Date: Wed, 6 Aug 2014 21:17:44 +0200
Message-ID: <20140806191744.GB6611@netboy>
References: <bbcbf584e3624059bf7a0d2186fec6b4@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Nick Krause <xerofoify@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <bbcbf584e3624059bf7a0d2186fec6b4@FE-MBX1012.de.bosch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 06, 2014 at 02:32:16PM +0000, Koehrer Mathias (ETAS/ESW5) wrote:
> With the Intel 82527EI (driver: e1000e) there is an issue when running 
> the ptpd2 program, that leads to a kernel oops.
> The reason is here that in e1000_xmit_frame() a work queue will be 
> scheduled that has not been initialized in this case.
> The work queue "tx_hwstamp_work" will only be initialized if 
> adapter->flags & FLAG_HAS_HW_TIMESTAMP set.
> This check is missing in e1000_xmit_frame().

Why all the ragged lines?  Better to use an editor that knows how to
justify a paragraph, more like this:

With the Intel 82527EI (driver: e1000e) there is an issue when running
the ptpd2 program, that leads to a kernel oops.  The reason is here
that in e1000_xmit_frame() a work queue will be scheduled that has not
been initialized in this case.  The work queue "tx_hwstamp_work" will
only be initialized if adapter->flags & FLAG_HAS_HW_TIMESTAMP set.
This check is missing in e1000_xmit_frame().

That not only looks nicer, but it is also more readable.

Thanks,
Richard
