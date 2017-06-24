From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/3] ethtool: support for forward error
 correction mode setting on a link
Date: Sat, 24 Jun 2017 23:47:42 +0200
Message-ID: <20170624214742.GO4875@lunn.ch>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linville@tuxdriver.com,
        netdev@vger.kernel.org, vidya.chowdary@gmail.com,
        dustin@cumulusnetworks.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        galp@mellanox.com, jeffrey.t.kirsher@intel.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34064 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752238AbdFXVry (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Jun 2017 17:47:54 -0400
Content-Disposition: inline
In-Reply-To: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 24, 2017 at 12:19:42PM -0700, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Forward Error Correction (FEC) modes i.e Base-R
> and Reed-Solomon modes are introduced in 25G/40G/100G standards
> for providing good BER at high speeds. Various networking devices
> which support 25G/40G/100G provides ability to manage supported FEC
> modes and the lack of FEC encoding control and reporting today is a
> source for itneroperability issues for many vendors.

interoperability. The same typ0 exists in the first patch

> FEC capability as well as specific FEC mode i.e. Base-R
> or RS modes can be requested or advertised through bits D44:47 of base link
> codeword.

For my own education, is this logically a MAC or a PHY thing?  Is the
negotiation performed at the PHY level, and then FEC happens at the
MAC level?

I'm just trying to look ahead when we start getting 25G/40G/100G PHY
support. Does phylib need an extension, similar to how pause is
negotiated at the PHY, and then the MAC does the actual work?

	 Andrew
