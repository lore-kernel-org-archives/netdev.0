From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Sun, 30 Sep 2007 15:23:25 -0400
Message-ID: <46FFF7AD.7090309@garzik.org>
References: <1191174077.6165.11.camel@localhost>	 <46FFE809.8020504@intel.com> <1191178881.6165.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54333 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751262AbXI3TXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Sep 2007 15:23:30 -0400
In-Reply-To: <1191178881.6165.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sun, 2007-30-09 at 11:16 -0700, Kok, Auke wrote:
> 
>> no, all the hardware that is commented should work just fine. I tested this driver
>> on 82571, 82573 and ich8/ich9 - extensively.
> 
> Something else is wrong then. Can you just uncomment the 82571EB bits in
> Dave's net-2.6.24 and just send a ping? If it works, let me know what
> you did so i can test next time i get a chance.
> 
>> the reason that we disable them is that we're going to migrate devices over in
>> batches. At introduction we'll support ich9, afterwards we'll drop in the IDs of
>> the other groups of silicon.
> 
> Turn them on if you want people to start using that driver.

Gotta wait a bit, otherwise we have confusion and a bit of breakage from 
two drivers with the same PCI IDs.

	Jeff


