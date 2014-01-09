From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 31/31] staging: r8188eu: Fix smatch error
Date: Wed, 8 Jan 2014 19:18:40 -0800
Message-ID: <20140109031840.GA14746@kroah.com>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
 <1387755422-11443-32-git-send-email-Larry.Finger@lwfinger.net>
 <20140102084410.GY28413@mwanda>
 <52C5E5F5.8030200@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:45553 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319AbaAIDSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 22:18:10 -0500
Content-Disposition: inline
In-Reply-To: <52C5E5F5.8030200@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 04:19:33PM -0600, Larry Finger wrote:
> On 01/02/2014 02:44 AM, Dan Carpenter wrote:
> >On Sun, Dec 22, 2013 at 05:37:02PM -0600, Larry Finger wrote:
> >>Smatch shows the following:
> >>
> >>   CHECK   drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
> >>drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:1401 OnAssocReq() error: buffer overflow 'pstapriv->sta_aid' 32 <= 32
> >>
> >
> >This is a false positive in Smatch.  Don't do work arounds for buggy
> >tools.
> >
> >If you have the cross function database built on the latest version of
> >Smatch then I think it understands the code correctly and doesn't print
> >a warning.
> 
> When I analyzed the loop in question, I thought it resulted in a subscript
> of [NUM_STA], but I now see that the largest one is [NUM_STA-1]. I will drop
> this patch in the next round.
> 
> Thanks for the info regarding a new version of Smatch. I'll update now.

Ok, I've applied the first 30, but dropped this patch.

thanks,

greg k-h
