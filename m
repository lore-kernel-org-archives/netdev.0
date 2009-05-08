From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: introduce a list of device addresses dev_addr_list
 (v6)
Date: Fri, 8 May 2009 15:38:42 -0700
Message-ID: <20090508153842.65ce3bed@s6510>
References: <20090418085848.GC3370@psychotron.englab.brq.redhat.com>
	<20090504111417.GE3402@psychotron.englab.brq.redhat.com>
	<20090505124827.GB3473@psychotron.englab.brq.redhat.com>
	<20090505.122718.51237316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com,
	ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42497 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350AbZEHWis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 18:38:48 -0400
In-Reply-To: <20090505.122718.51237316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 May 2009 12:27:18 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jiri Pirko <jpirko@redhat.com>
> Date: Tue, 5 May 2009 14:48:28 +0200
> 
> > This patch introduces a new list in struct net_device and brings a set of
> > functions to handle the work with device address list. The list is a replacement
> > for the original dev_addr field and because in some situations there is need to
> > carry several device addresses with the net device. To be backward compatible,
> > dev_addr is made to point to the first member of the list so original drivers
> > sees no difference.
> > 
> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Applied to net-next-2.6, thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Not sure if this is such a good idea since the purpose of this was to fix
a bonding/bridging interaction, but it breaks STP on bridging.
