From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: Ethernet MAC address question
Date: Tue, 15 Jun 2004 08:38:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406151538.i5FFcJ720553@localhost.localdomain>
References: <20040615095817.GA16523@projectcolo.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: broonie@sirena.org.uk (Mark Brown)
In-Reply-To: <20040615095817.GA16523@projectcolo.org.uk> from "Mark Brown" at Jun 15, 2004 10:58:17 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

So how does the driver distinguish between a valid, but incorrect MAC
address, and the 'correct' MAC address?  The incorrect one that is the
value that just happened to be in the uninitialized volatile registers,
and the correct address which some magic platform means loaded into the
same, but this time initialized, volatile registers.

> > However there are a few cases where some magic platform means loads the 
> > MAC address into the (volatile) MAC address registers, and that's the 
> > only source of an accurate MAC address for those people.
> 
> This is reasonably common on embedded systems - often there won't be
> SEPROMs for individual devices and the MAC address will be stored in
> flash or similar and read by the bootloader.
> 

-- 
Don Fry
brazilnut@us.ibm.com
