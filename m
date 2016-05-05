From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: [PATCH net-next] vxlan: if_arp: introduce ARPHRD_VXLANGPE
Date: Thu, 5 May 2016 16:56:43 -0300
Message-ID: <20160505195643.GA14919@indiana.gru.redhat.com>
References: <1462466204-3534-1-git-send-email-cascardo@redhat.com>
 <20160505213141.7ad29ebd@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756279AbcEET4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 15:56:49 -0400
Content-Disposition: inline
In-Reply-To: <20160505213141.7ad29ebd@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 09:31:41PM +0200, Jiri Benc wrote:
> On Thu,  5 May 2016 13:36:44 -0300, Thadeu Lima de Souza Cascardo wrote:
> > Use ARPHRD_VXLANGPE to identify VxLAN GPE interfaces. This is going to be used
> > to allow GPE interfaces to be added as openvswitch ports.
> 
> What's wrong with ARPHRD_NONE? I don't think we need a separate type
> for VXLAN-GPE. Just use ARPHRD_NONE in ovs and things should work, for
> all ARPHRD_NONE interfaces as a bonus.
> 

That's fine for me. I looked quickly at the few devices using ARPHRD_NONE in
upstream kernel, not sure if there are broken out-of-tree drivers out there. And
should we care?

> > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> > Cc: Jiri Benc <jbenc@redhat.com>
> > Cc: Simon Horman <simon.horman@netronome.com>
> 
> You did not CC me nor Simon :-)
> 

I am using sendemail.suppresscc=all to prevent some accidents. I am adding
confirm=always so I can double check before really sending.

Thanks.
Cascardo.

>  Jiri
