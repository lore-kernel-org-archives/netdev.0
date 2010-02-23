From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 v3 00/12] net-caif: introducing CAIF protocol stack
Date: Tue, 23 Feb 2010 08:39:52 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E07903359AE7@eseldmw101.eemea.ericsson.se>
References: <1266876331-23988-1-git-send-email-sjur.brandeland@stericsson.com> <1266910387.18491.54.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>,
	<kaber@trash.net>, <stefano.babic@babic.homelinux.org>,
	<randy.dunlap@oracle.com>
To: "Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:62822 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab0BWHjz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 02:39:55 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1266910387.18491.54.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel.
>> CHANGE LOG:
>> Based on review comments from David Miller and Marcel Holtmann on the
>> previous patch set submitted the 16 February the following changes
>> have been done: 
>> - Removed ifdef __cplusplus from caif_socket.h
>> - Use socket level SOL_IP for socket options SO_PRIORITY and
>> SO_BINDTODEVICE
> 
> are you sure it is not better to use SOL_SOCKET here. At least
> according to man 7 socket this would make a lot more sense. My point
> in actually using SO_PRIORITY and SO_BINDTODEVICE is to use standard
> socket options that are already used by everybody else. So they know
> what to expect.    
> 
Yes, this makes sense. I'll update this.

BR/Sjur
