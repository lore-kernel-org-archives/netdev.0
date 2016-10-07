From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net] xen-netback: make sure that hashes are not send to
 unaware frontends
Date: Fri, 7 Oct 2016 07:49:28 +0000
Message-ID: <53e1696c79a447c3929267dc3de7dc82@AMSPEX02CL03.citrite.net>
References: <1475765230-11936-1-git-send-email-paul.durrant@citrix.com>
 <20161007.013801.2201234350691558646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        Wei Liu <wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:62153 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754169AbcJGHtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 03:49:31 -0400
In-Reply-To: <20161007.013801.2201234350691558646.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 07 October 2016 06:38
> To: Paul Durrant <Paul.Durrant@citrix.com>
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org; Wei Liu
> <wei.liu2@citrix.com>
> Subject: Re: [PATCH net] xen-netback: make sure that hashes are not send
> to unaware frontends
> 
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Thu, 6 Oct 2016 15:47:10 +0100
> 
> > In the case when a frontend only negotiates a single queue with xen-
> > netback it is possible for a skbuff with a s/w hash to result in a
> > hash extra_info segment being sent to the frontend even when no hash
> > algorithm has been configured. (The ndo_select_queue() entry point
> > makes sure the hash is not set if no algorithm is configured, but this
> > entry point is not called when there is only a single queue). This can
> > result in a frontend that isunable to handle extra_info segments being
> > given such a segment, causing it to crash.
> >
> > This patch fixes the problem by gating whether the extra_info is sent
> > not only on the presence of a s/w hash, but also on whether the hash
> > algorithm has been configured.
> >
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > Cc: Wei Liu <wei.liu2@citrix.com>
> 
> This doesn't apply cleanly to the current 'net' tree, please respin.
> 

Sure. V2 coming.

  Paul

> Thanks.
