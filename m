From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Wed, 28 Jun 2017 15:41:39 +0200
Message-ID: <20170628134139.GB12559@lunn.ch>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <20170627032239.05cdc462@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
        linville@tuxdriver.com, netdev@vger.kernel.org,
        vidya.chowdary@gmail.com, dustin@cumulusnetworks.com,
        olson@cumulusnetworks.com, leedom@chelsio.com,
        manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        galp@mellanox.com, jeffrey.t.kirsher@intel.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37851 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751544AbdF1Nlp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 09:41:45 -0400
Content-Disposition: inline
In-Reply-To: <20170627032239.05cdc462@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 03:22:39AM -0700, Jakub Kicinski wrote:
> On Sat, 24 Jun 2017 12:19:43 -0700, Roopa Prabhu wrote:
> > Encoding: Types of encoding
> > Off    :  Turning off any encoding
> > RS     :  enforcing RS-FEC encoding on supported speeds
> > BaseR  :  enforcing Base R encoding on supported speeds
> > Auto   :  IEEE defaults for the speed/medium combination
> 
> Just to be sure - does auto mean autonegotiate as defined by IEEE or
> some presets?

I don't know this field very well. Is this confusion likely to happen
a lot? Is there a better name for Auto which is less likely to be
confused?

	Andrew
