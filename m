From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 15:24:16 +0100
Message-ID: <20161125142416.GB22642@kroah.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
 <20161125002702.GA14085@electric-eye.fr.zoreil.com>
 <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com>
 <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        David Miller <davem@davemloft.net>, hayeswang@realtek.com,
        netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Mark Lord <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:46028 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754263AbcKYOgd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 09:36:33 -0500
Content-Disposition: inline
In-Reply-To: <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 07:49:35AM -0500, Mark Lord wrote:
> On 16-11-25 04:53 AM, Greg KH wrote:
> > On Thu, Nov 24, 2016 at 10:49:33PM -0500, Mark Lord wrote:
> >> There is no possibility for them to be used for anything other than
> >> USB receive buffers, for this driver only.  Nothing in the driver
> >> or kernel ever writes to those buffers after initial allocation,
> >> and only the driver and USB host controller ever have pointers to the buffers.
> > 
> > You really are going to have to break out that USB monitor to verify
> > that this is the data coming across the wire.
> 
> Not sure why, because there really is no other way for the data to
> appear where it does at the beginning of that URB buffer.

Broken USB host controller driver, or the device really is sending that
data to the host.  It's either one or the other, and the only way you
can rule one of them out is to look at the data on the wire.

best of luck,

greg k-h
