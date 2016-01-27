From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 1/2] of: of_mdio: Add a whitelist of PHY
 compatibilities.
Date: Wed, 27 Jan 2016 15:03:50 +0100
Message-ID: <20160127140350.GA18319@lunn.ch>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
 <1453853499-11248-2-git-send-email-andrew@lunn.ch>
 <56A8CB6A.2070101@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	aaro.koskinen@nokia.com, olof@lixom.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43751 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754265AbcA0ODy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 09:03:54 -0500
Content-Disposition: inline
In-Reply-To: <56A8CB6A.2070101@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2016 at 04:51:38PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/27/2016 03:11 AM, Andrew Lunn wrote:
> 
> >Some phy nodes list a compatible value indicating the PHY make/model.
> >This is never used to match the device to the driver. However it does
> >confuse the code to separate a PHY from a generic MDIO device like a
> >switch. Generic MDIO devices must have a compatible value, PHYs can
> >list clause 22 or 45, but nothing else.
> >
> >Issue a warning if we find a compatible value known on the whitelist,
> 
>    My spell-checker trips on "whitelist"... Perhaps a space/hyphen needed?

$ dict whitelist
1 definition found

>From The Jargon File (version 4.4.7, 29 Dec 2003) [jargon]:

  whitelist
   n.
  
          The opposite of a blacklist. That is, instead of being an explicit
          list of people who are banned, it's an explicit list of people who
          are to be admitted. Hackers use this especially of lists of email
          addresses that are explicitly enabled to get past strict anti-spam
          filters.

> >+/* The following is a list of PHY compatible strings which appear in
> >+ * some DTBs. The compatible string is never matched against a PHY
> >+ * driver, so is pointless. We only expect devices which are not PHYs
> >+ * to have a compatible string, so they can be matched to an MDIO
> >+ * driver.  Encourage users to upgrade there DT blobs to remove these.
> 
>    s/there/their/.

I will fix this.

  Andrew
