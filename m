From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: Ethernet MAC address question
Date: Tue, 15 Jun 2004 10:58:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615095817.GA16523@projectcolo.org.uk>
References: <200406142202.i5EM2bh19464@localhost.localdomain> <40CE361A.9060707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <40CE361A.9060707@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 14, 2004 at 07:34:50PM -0400, Jeff Garzik wrote:

> However there are a few cases where some magic platform means loads the 
> MAC address into the (volatile) MAC address registers, and that's the 
> only source of an accurate MAC address for those people.

This is reasonably common on embedded systems - often there won't be
SEPROMs for individual devices and the MAC address will be stored in
flash or similar and read by the bootloader.

-- 
"You grabbed my hand and we fell into it, like a daydream - or a fever."
