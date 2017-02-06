From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Mon, 6 Feb 2017 10:14:44 +0200
Message-ID: <20170206081444.smcgjkmdepxoosb6@p310>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165603.GV3442@decadent.org.uk>
 <20170205003038.GB21184@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org,
        Lisandro =?utf-8?Q?Dami=C3=A1n_Nicanor_P=C3=A9rez?= Meyer
        <lisandro@debian.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:54194 "EHLO
        zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751135AbdBFIyi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 03:54:38 -0500
Content-Disposition: inline
In-Reply-To: <20170205003038.GB21184@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-05 01:30:39, Greg KH wrote:
> On Sat, Feb 04, 2017 at 04:56:03PM +0000, Ben Hutchings wrote:
> > Allocating USB buffers on the stack is not portable, and no longer
> > works on x86_64 (with VMAP_STACK enabled as per default).
> 
> It's never worked on other platforms, so these should go to the stable 
> releases please.

As far as i know both drivers works fine on other platforms, though I only 
tested it on arm and mipsel. ;)

Random thought: isn't it better to add the alloc/free code in usb_control_msg() 
and avoid code duplication all over the driver space?


cheers,
Petko
