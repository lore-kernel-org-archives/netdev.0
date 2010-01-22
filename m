From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 03/13] net-caif: add CAIF generic protocol stack header files
Date: Fri, 22 Jan 2010 12:02:19 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079032320DE@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-4-git-send-email-sjur.brandeland@stericsson.com> <4B580C96.1040509@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<marcel@holtmann.org>, <stefano.babic@babic.homelinux.org>,
	<randy.dunlap@oracle.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:56772 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382Ab0AVLCt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 06:02:49 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B580C96.1040509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick.

Patrick McHardy wrote:
> sjur.brandeland@stericsson.com wrote:
>> +++ b/include/net/caif/generic/cfglue.h
... 
> This file looks like it should go away completely.
...
> Why are you not using the list.h functions?

I kind of expected this feedback.
The reason is that CAIF originally was written as a OS independent stack, 
with a thin glue layer for OS specific things.
I am aware that this is not the preferred way of doing it in the Linux kernel.
As mentioned to Marcel Holtmann, my problem is that I have more than 50 unit
tests in User Space that I might have to ditch if I remove cfglue.h and list.h.

But I'll probably do as you suggest in the next patch set...

BR/Sjur


