From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [RFC 56/72] macb: Move the Atmel driver
Date: Mon, 27 Jun 2011 10:29:20 +0100
Message-ID: <20110627092920.GB2613@pulham.picochip.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1309010363-22750-57-git-send-email-jeffrey.t.kirsher@intel.com>
 <4E083572.6050302@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jamie Iles <jamie@jamieiles.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62494 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757343Ab1F0J3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 05:29:25 -0400
Received: by wwe5 with SMTP id 5so4576352wwe.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 02:29:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4E083572.6050302@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2011 at 09:46:58AM +0200, Nicolas Ferre wrote:
> Hi,
> 
> Le 25/06/2011 15:59, Jeff Kirsher :
> > Move the Atmel driver into drivers/net/ethernet/atmel/ and
> 
> I am not sure that "atmel" is the proper name for a directory containing
> the macb.c driver. This controller has not been made by atmel and will
> be shared with others soon (Cf. paches by Jamie Iles).
> 
> So two questions remains:
> - will we need to have a directory for this driver?
> - what will be the name of this directory?

The MACB is actually a Cadence IP block and I have a set of patches that 
add support for the Cadence GEM	so personally I'd be happy with 
drivers/net/ethernet/cadence.

Jamie
