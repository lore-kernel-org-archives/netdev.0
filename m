From: <Parav.Pandit@Emulex.Com>
Subject: RE: [RFC 2/2] be2net: Added functionality to support RoCE driver
Date: Thu, 8 Mar 2012 09:49:06 -0800
Message-ID: <88B766C272F2C64B944B21AD078333151C956BD34E@EXMAIL.ad.emulex.com>
References: <3cd7ea39-a8d3-4d63-9753-0c64fb7e3609@exht1.ad.emulex.com>,<AE90C24D6B3A694183C094C60CF0A2F6026B6E94@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <David.Laight@ACULAB.COM>, <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:41608 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752378Ab2CHR42 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 12:56:28 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E94@saturn3.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


________________________________________
From: David Laight [David.Laight@ACULAB.COM]
Sent: Thursday, March 08, 2012 7:08 PM
To: Pandit, Parav; romieu@fr.zoreil.com
Cc: netdev@vger.kernel.org
Subject: RE: [RFC 2/2] be2net: Added functionality to support RoCE driver

> > > + void *ocrdma_dev;
>
> > > Is there a reason why it could not be 'struct ocrdma_dev *o' ?
> [Parav] Yes. Reason is NIC driver publishes interface to RoCE
> driver. NIC driver is not aware of ocrdma_dev structure.
> So its void pointer.

If the argument can only ever be 'struct ocrdma_dev *'
then used the named structure pointer - you don't need to
expose the actual definition to the other drivers.

Makes it much more difficult to pass the address of an
inappropriate structure.
[Parav] If I understand correctly, I should do following.

Instead of void* in add(), remove(), event_handler(), 
it should be struct ocrdma_dev* with forward declaration.

Is that correct understanding?

        David
