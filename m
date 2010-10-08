From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Add Qualcomm Gobi 2000 driver.
Date: Fri, 08 Oct 2010 11:14:06 -0700 (PDT)
Message-ID: <20101008.111406.246542521.davem@davemloft.net>
References: <20101006151208.GB1571@google.com>
	<20101008.102803.104075511.davem@davemloft.net>
	<20101008180310.GA27126@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ellyjones@google.com, netdev@vger.kernel.org, jglasgow@google.com,
	msb@google.com, olofj@google.com
To: mjg59@srcf.ucam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43693
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754336Ab0JHSNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 14:13:45 -0400
In-Reply-To: <20101008180310.GA27126@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Garrett <mjg59@srcf.ucam.org>
Date: Fri, 8 Oct 2010 19:03:10 +0100

> On Fri, Oct 08, 2010 at 10:28:03AM -0700, David Miller wrote:
> 
>> I've looked at the gobi_loader code and it's simpler than many
>> of the gigabit ethernet driver firmware loader sequences in
>> the tree already.
>> 
>> Requiring udev et al. magic only makes this networking device
>> that much harder to use from an initrd.
>> 
>> I understand how this might be a bit clumsy since we'd need to make a
>> dependency on the serial device since that is the mechanism by which
>> the firmware is uploaded, but really I'd like you to consider it
>> seriously.
> 
> The device is capable of functioning in either UMTS or CDMA modes, and 
> requires different firmware for each. Further, there's separate firmware 
> images per carrier due to regulatory differences. To make things even 
> more complicated, there's no consistency in the naming of the firmware 
> (and we can't fix that, because the firmware is undistributable). The 
> only way to do this in-kernel would seem to be to have a module 
> parameter to pass a firmware name, which really doesn't seem elegant.

I don't think we want a driver in the tree for a device for which the
firmware isn't even distributable.
