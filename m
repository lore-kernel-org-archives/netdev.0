From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC 2/2] be2net: Added functionality to support RoCE driver
Date: Thu, 8 Mar 2012 13:38:31 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E94@saturn3.aculab.com>
References: <3cd7ea39-a8d3-4d63-9753-0c64fb7e3609@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <Parav.Pandit@Emulex.Com>, <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:32937 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752085Ab2CHNj1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 08:39:27 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25179-09 for <netdev@vger.kernel.org>;
 Thu,  8 Mar 2012 13:39:22 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <3cd7ea39-a8d3-4d63-9753-0c64fb7e3609@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > > +	void *ocrdma_dev;
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

	David
