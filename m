From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] Net Driver: Add Cypress GX3 VID=04b4 PID=3610.
Date: Tue, 27 Sep 2016 17:40:26 +0200
Message-ID: <20160927154026.GA887@kroah.com>
References: <271e26e7350f418bad08761cab439005@Mail06.usask.ca>
 <CAPZMiRa6=So14ic8SMSkbHdrVH8-7vA1+Wg_hWJoAgr8G_mhyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Chris Roth <chris.roth@usask.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:40182 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932297AbcI0PkX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 11:40:23 -0400
Content-Disposition: inline
In-Reply-To: <CAPZMiRa6=So14ic8SMSkbHdrVH8-7vA1+Wg_hWJoAgr8G_mhyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2016 at 03:56:59PM -0600, Chris Roth wrote:
> I'm not sure what I'm doing wrong:
> 
> I'm trying to get the from statement to read original author (Allan
> Chou) first, and then me (Chris Roth) second. I've used the following
> two commands:
> 
> git format-patch -o /tmp/ --subject-prefix="PATCH v2" --from="Allan
> Chou <allan@asix.com.tw>" HEAD^
> 
> and
> 
> git send-email --to linux-usb@vger.kernel.org --to
> netdev@vger.kernel.org --to linux-kernel@vger.kernel.org --from="Allan
> Chou <allan@asix.com.tw>"
> /tmp/0001-Net-Driver-Add-Cypress-GX3-VID-04b4-PID-3610.patch
> 
> I thought that adding the --from portions to the git format-patch and
> git send-email commands would force the addition of Allan to the top
> of the patch, but it hasn't. Can anyone tell me specifically how I
> need to change these commands in order to get the desired result? Then
> I'll submit a PATCH v3.

Take the patch that you have, hand-edit it with your favorite editor to
have the correct headers and signed-off-by and other fields, and then
use git send-email without the --from line, and you should be fine.

thanks,

greg k-h
