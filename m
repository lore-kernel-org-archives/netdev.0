From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Tue, 11 Oct 2016 19:37:32 +0200
Message-ID: <1476207452.448.2.camel@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
         <20161011173216.GA16892@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50826 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932252AbcJKRhg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 13:37:36 -0400
In-Reply-To: <20161011173216.GA16892@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-11 at 11:32 -0600, Jason Gunthorpe wrote:
> On Tue, Oct 11, 2016 at 07:15:44PM +0200, Paolo Abeni wrote:
> 
> > Also the connected mode maximum mtu is reduced by 16 bytes to
> > cope with the increased hard header len.
> 
> Changing the MTU is going to cause annoying interop problems, can you
> avoid this?

I don't like changing the maximum MTU value, too, but I was unable to
find an alternative solution. The PMTU detection should protect against
such issues. 
