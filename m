From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 v3 00/12] net-caif: introducing CAIF protocol stack
Date: Sat, 27 Feb 2010 11:05:14 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079138CB8@eseldmw101.eemea.ericsson.se>
References: <1266876331-23988-1-git-send-email-sjur.brandeland@stericsson.com><1266910387.18491.54.camel@violet><61D8D34BB13CFE408D154529C120E07903359AE7@eseldmw101.eemea.ericsson.se> <20100226.012204.67216627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <marcel@holtmann.org>, <netdev@vger.kernel.org>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>,
	<kaber@trash.net>, <stefano.babic@babic.homelinux.org>,
	<randy.dunlap@oracle.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:64696 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964877Ab0B0KUY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 05:20:24 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>> Hi Marcel.
>>>> CHANGE LOG:
>>>> Based on review comments from David Miller and Marcel Holtmann on the
>>>> previous patch set submitted the 16 February the following changes
>>>> have been done: 
>>>> - Removed ifdef __cplusplus from caif_socket.h
>>>> - Use socket level SOL_IP for socket options SO_PRIORITY and
>>>> SO_BINDTODEVICE
>>> 
>>> are you sure it is not better to use SOL_SOCKET here. At least
>>> according to man 7 socket this would make a lot more sense. My point
>>> in actually using SO_PRIORITY and SO_BINDTODEVICE is to use standard
>>> socket options that are already used by everybody else. So they know
>>> what to expect.    
>>> 
>> Yes, this makes sense. I'll update this.
>
>Please fix this up and resubmit your patch series so I can add
>it to the net-next-2.6 tree.

I have sent a V4 patch-set, fixing the review comments on the 
V3 patch-set. But there are still review comments coming in.

Unfortunately, I am traveling until Thursday this week, without Internet access,
so if you would like me to resubmit again I will not be able to do that before
Thursday or Friday this week.

BR/Sjur
