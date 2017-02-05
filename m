From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Sun, 5 Feb 2017 01:30:39 +0100
Message-ID: <20170205003038.GB21184@kroah.com>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165603.GV3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        Petko Manolov <petkan@nucleusys.com>,
        Lisandro =?iso-8859-1?Q?Dami=E1n_Nicanor_P=E9rez?= Meyer
        <lisandro@debian.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48624 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751660AbdBEAaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 19:30:35 -0500
Content-Disposition: inline
In-Reply-To: <20170204165603.GV3442@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 04:56:03PM +0000, Ben Hutchings wrote:
> Allocating USB buffers on the stack is not portable, and no longer
> works on x86_64 (with VMAP_STACK enabled as per default).

It's never worked on other platforms, so these should go to the stable
releases please.

thanks,

greg k-h
