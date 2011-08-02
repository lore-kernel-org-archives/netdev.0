From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Tue, 2 Aug 2011 15:45:34 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1108021544360.2158-100000@iolanthe.rowland.org>
References: <201108022030.21331.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Orishko <alexey.orishko@gmail.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-usb@vger.kernel.org>, <gregkh@suse.de>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:54923 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754697Ab1HBTpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 15:45:35 -0400
In-Reply-To: <201108022030.21331.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Aug 2011, Oliver Neukum wrote:

> Am Dienstag, 2. August 2011, 18:20:26 schrieb Alexey Orishko:
> > Changes:
> > - removed redandunt conversion for usb control requests
> > - added missing conversion for nth16.wNdpIndex
> > Thanks to Giuseppe Scrivano for providing fixes
> 
> What? How can a conversion of endianness be redundant?

When it's done twice.  :-)

> Either this version or the old version must be buggy. What is
> happening here?

The old version is buggy.  Read the code and you'll see.

Alan Stern

