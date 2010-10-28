From: David Miller <davem@davemloft.net>
Subject: Re: Future of the Wimedia LLC Protocol (WLP) subsystem/drivers
Date: Thu, 28 Oct 2010 09:29:43 -0700 (PDT)
Message-ID: <20101028.092943.193715325.davem@davemloft.net>
References: <4CBDC7B7.5070108@csr.com>
	<20101020091541.ec00fe96.randy.dunlap@oracle.com>
	<20101020192233.GA8912@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, david.vrabel@csr.com,
	netdev@vger.kernel.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752675Ab0J1Q3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 12:29:20 -0400
In-Reply-To: <20101020192233.GA8912@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Wed, 20 Oct 2010 12:22:33 -0700

> On Wed, Oct 20, 2010 at 09:15:41AM -0700, Randy Dunlap wrote:
>> On Tue, 19 Oct 2010 17:30:47 +0100 David Vrabel wrote:
>> 
>> > Hi,
>> > 
>> > I've have been nominally the maintainer of the Wimedia LLC Protocol
>> > (WLP) subsystem and driver since it was originally submitted.  I am no
>> > longer in a position to even pretend to be a maintainer.
>> > 
>> > The only usable hardware was an Intel i1480 devices with beta firmware
>> > that was never released as a product.  Intel have since sold all there
>> > UWB/WLP IP and I see little prospect of there ever being hardware
>> > commercially available for WLP.
>> > 
>> > Here are a number of options:
>> > 
>> > 1. Someone else maintains it.  Any volunteers?
>> > 
>> > 2. It gets labelled as Orphaned in MAINTAINERS.
>> > 
>> > 3. It gets moved to staging.
>> > 
>> > 4, It gets removed.
>> > 
>> > If no one says anything I'll submit a patch to Linus to mark it as Orphaned.
>> 
>> I'd say either 3 or 4.
>> 
>> It could go to staging on it way to removal, but that's not really necessary.
>> 
>> 
>> cc: gregkh
> 
> 3 or 4 is fine with me, which ever David wants.

I'm fine with either but prefer 4, if we want to resurrect the code
for whatever reason it is there in the history and we can just revert
the revert commit to get it all back.
