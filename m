From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH] man ip-link: Add more explanation about vlan reordering
Date: Wed, 16 Sep 2015 19:58:01 +0300
Message-ID: <20150916165801.GA12824@angus-think.lan>
References: <1439839344-12772-1-git-send-email-vadim4j@gmail.com>
 <55DDDAF4.30904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Jeremy Harris <jgh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33044 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbbIPRBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 13:01:18 -0400
Received: by wiclk2 with SMTP id lk2so82633323wic.0
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 10:01:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55DDDAF4.30904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 04:27:48PM +0100, Jeremy Harris wrote:
> On 17/08/15 20:22, Vadim Kochan wrote:
> > +.BR reorder_hdr " is " on
> > +then VLAN header will be not inserted immediately but only before passing to the
> > +physical device (if this device does not support VLAN offloading), the similar
> > +on the RX direction - by default the packet will be untagged before being
> > +received by VLAN device. Reordering allows to accelerate tagging on egress and
> > +to hide VLAN header on ingress so the packet looks like regular Ethernet packet,
> > +at the same time it might be confusing while the packet sniffing as the VLAN header
>                                           ^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> Does not read well.  "for packet capture" perhaps?
> -- 
> Jeremy
> 
> 

Hi Jeremy,

Thanks for you comment, I have sent a patch, let me know if it is correct now.
And sorry for so late response.

Thanks,
Vadim Kochan
