From: jamal <hadi@cyberus.ca>
Subject: Re: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Tue, 29 Jan 2008 18:08:28 -0500
Message-ID: <1201648108.4425.15.camel@localhost>
References: <20080129184726.GA29300@gateway.home>
	 <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com>
	 <1201640243.4431.29.camel@localhost>  <20080129214555.GC29300@gateway.home>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Erik Mouw <mouw@nl.linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:2626 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbYA2XIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 18:08:32 -0500
Received: by py-out-1112.google.com with SMTP id u52so5805pyb.10
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 15:08:31 -0800 (PST)
In-Reply-To: <20080129214555.GC29300@gateway.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-29-01 at 22:45 +0100, Erik Mouw wrote:

> > The driver seems buggy. Make it return NETDEV_TX_BUSY instead of -EIO
> > in xircom_start_xmit() and the messages will go away.
> 
> Like this?
> 

Indeed. 

Peter, I suspect that driver is just buggy in some other way as opposed
to being re-entered; couldnt tell by inspection. It is possible it may
be too eager to open up before it really has space.
It will be easy to check your theory by having the driver just check if
it is netif_stopped just before it returns NETDEV_TX_BUSY.

cheers,
jamal


