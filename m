From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 03/13] net-caif: add CAIF generic protocol stack header files
Date: Fri, 22 Jan 2010 11:01:39 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E07903232092@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-4-git-send-email-sjur.brandeland@stericsson.com> <1264152497.3469.20.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stefano.babic@babic.homelinux.org>, <randy.dunlap@oracle.com>
To: "Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:65363 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab0AVKGp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 05:06:45 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1264152497.3469.20.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel.

Marcel Holtmann wrote:
>> Add include files for the generic CAIF protocol stack. This layer is
>> somewhat generic in order to be able to use and test it outside the
>> Linux Kernel.
>> 
>> caif_layer.h - Defines the structure of the CAIF protocol layers
>> cfcnfg.h     - CAIF Configuration Module for services and link layers
>> cfctrl.h     - CAIF Control Protocol Layer
>> cffrml.h     - CAIF Framing Layer
>> cfglue.h     - CAIF Glue Layer for allocation, logging etc
>> cflist.h     - CAIF List implementation
>> cfmuxl.h     - CAIF Muxing Layer
>> cfpkt.h	     - CAIF Packet layer (skb helper functions)
>> cfserl.h     - CAIF Serial Layer
>> cfsrvl.h     - CAIF Service Layer
> 
> is it really needed to keep the "generic" piece in the path here. I
> would prefer if we get rid of it. 

Are you suggesting to move this files to include/net/caif? 
I can do this in the next patch set.
The reason for the term "generic" is that this that the core part of the CAIF
stack originally was designed to be OS independent. 

BR/Sjur
