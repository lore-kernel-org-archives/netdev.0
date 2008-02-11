From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] pegasus.c
Date: Mon, 11 Feb 2008 10:38:28 -0500
Message-ID: <47B06BF4.7010009@garzik.org>
References: <alpine.DEB.1.00.0801091222560.3171@bender.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39843 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753592AbYBKPib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 10:38:31 -0500
In-Reply-To: <alpine.DEB.1.00.0801091222560.3171@bender.nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Petko Manolov wrote:
>     Hi Jeff,
> 
> Attached you'll find a patch that is fixing a driver bug triggered when 
> malformed string is passed to the 'devid' module parameter.  The 
> expected format is:
> 
>     "device_name:vendor_id:device_id:flags"
> 
> but it turned out people often type:
> 
>     "somename::0"
> 
> instead of:
> 
>     "somename:::0"

ACK but two process problems preventing application:

* patch is base64-encoded

* no signed-off-by included


