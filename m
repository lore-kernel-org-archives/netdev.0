From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: net/eth/ibmveth: Fixup retrieval of MAC address
Date: Sat, 04 May 2013 07:17:32 +1000
Message-ID: <1367615852.4389.98.camel@pasglop>
References: <1367458520.4389.6.camel@pasglop>
	 <1367598632.2756.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	David Gibson <dwg@au1.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48799 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763497Ab3ECVRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 17:17:50 -0400
In-Reply-To: <1367598632.2756.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 17:30 +0100, Ben Hutchings wrote:
> > +	/* Workaround for old/broken pHyp */
> > +	if (mac_len == 8)
> > +		mac_addr_p += 2;
> > +	if (mac_len != 6) {
> 
> Missing 'else' before the second if?

Absolutely... oops :-) I couldn't find a version of pHyp with the wrong
property to test with. I suppose I could hack it up in OFW before boot.

I'll fix that and respin, sorry about that.

Cheers,
Ben.

> > +		dev_err(&dev->dev, "VETH_MAC_ADDR attribute wrong len %d\n",
> > +			mac_len);
> > +		return -EINVAL;
> > +	}
> [...]
> 
