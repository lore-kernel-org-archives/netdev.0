From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: introduce a list of device addresses dev_addr_list
 (v6)
Date: Fri, 8 May 2009 16:12:04 -0700
Message-ID: <20090508161204.134668b9@nehalam>
References: <20090505124827.GB3473@psychotron.englab.brq.redhat.com>
	<20090505.122718.51237316.davem@davemloft.net>
	<20090508153842.65ce3bed@s6510>
	<20090508.160008.127530143.davem@davemloft.net>
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
Received: from mail.vyatta.com ([76.74.103.46]:44116 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbZEHXMM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 19:12:12 -0400
In-Reply-To: <20090508.160008.127530143.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 May 2009 16:00:08 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 8 May 2009 15:38:42 -0700
> 
> > Not sure if this is such a good idea since the purpose of this was to fix
> > a bonding/bridging interaction, but it breaks STP on bridging.
> 
> Thanks for not paying attention... :-/
> 
> The Intel folks want to have an address list functionality so
> they can public MAC addresses meant for FCOE and other purposes.
> 
> So even if the bonding bits bomb, we still need this.

But the other infrastructure may have same issues (netfilter, etc).
Just seems like it would be either to have multiple network devices
so that upper layers could disambiguate easier.

-- 
