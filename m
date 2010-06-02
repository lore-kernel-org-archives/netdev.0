From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Wed, 2 Jun 2010 17:08:51 +0200
Message-ID: <20100602150851.GA22591@riccoc20.at.omicron.at>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
 <AANLkTilKJVZiKLRUlL7AeaqSnlAs2u5sTW7o2vfvEKns@mail.gmail.com>
 <20100602125527.GA20396@riccoc20.at.omicron.at>
 <20100602.065017.139108801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: afleming@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:58016 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758365Ab0FBPIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:08:20 -0400
Received: by fg-out-1718.google.com with SMTP id d23so12833fga.1
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 08:08:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100602.065017.139108801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 02, 2010 at 06:50:17AM -0700, David Miller wrote:
> phy_device->priv "could one day get used for a different purpose"?
> What in the world are you smoking Andy?

I think he meant that the 'priv' pointer may one day be used to point
to some dynamically allocated data structure.

> It's clearly a private state pointer for the PHY driver to use,
> full stop.  There is absolutely no ambiguity of what this value
> is and what it is used for and who owns it.  The comments in the
> layout of struct phy_device state this clearly as well.
...
>
> Richard, please respin your patch so that you're using the ->priv
> field like in your original patch.

Well, is it okay to just use the first patch?

The fix needs just one bit of data, and I thought that (ab)using the
'priv' pointer would be okay, if a bit hacky. If, over time, the
driver needs more private data, it should be clear enought that the
existing bit "fiber selected" will also appear in the data structure.

Otherwise, the driver would have to allocate a structure with one
field, just to remember one bit.

Richard
