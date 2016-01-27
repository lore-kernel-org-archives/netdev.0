From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Wed, 27 Jan 2016 18:11:09 +0100
Message-ID: <20160127171109.GE20194@lunn.ch>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
 <1453853499-11248-3-git-send-email-andrew@lunn.ch>
 <CAOesGMj6OKYY6thjKX_t-ABogSNrSuQ7rbWPPvhGRtdOTJtXiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Aaro Koskinen <aaro.koskinen@nokia.com>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44010 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754261AbcA0RLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 12:11:12 -0500
Content-Disposition: inline
In-Reply-To: <CAOesGMj6OKYY6thjKX_t-ABogSNrSuQ7rbWPPvhGRtdOTJtXiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2016 at 08:41:56AM -0800, Olof Johansson wrote:
> On Tue, Jan 26, 2016 at 4:11 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> > PHY devices may only list clause 22, 45, and their PHY identifier
> > values as compatible values. No other compatible strings are allowed.
> > Make this clear in the documentation, and remove examples where
> > make/model compatible strings are listed.
> >
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> 
> I'm not sure I agree with the disallowing here. It's common practice
> to use a specific compatible to describe the actual hardware used, in
> case it's needed in the future for some driver to distinguish
> behavior, etc.
> 
> So while it should be required to include the clause compats, having a
> more specific one in there should be acceptable.

Hi Olof

Matching PHY devices to drivers has never used to compatible string,
other than the "ethernet-phy-XXXX.YYYY" string.  The PHY has two
registers containing a manufacture id, device id and revision,
registers 2 and 3. These are the XXXX and YYYY. The core code reads
these values, or uses the values from the ethernet-phy-XXXX.YYYY, and
uses them to find a driver which supports these values.

A make/model string is less specific than ethernet-phy-XXXX.YYYY.

I will reword the changelog to make it clear that
"ethernet-phy-XXXX.YYYY" is allowed.

Thanks
	Andrew
