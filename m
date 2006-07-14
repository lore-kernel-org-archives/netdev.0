From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VLAN code can use the faster ether_compare_addr
Date: Fri, 14 Jul 2006 16:34:40 -0700 (PDT)
Message-ID: <20060714.163440.51519318.davem@davemloft.net>
References: <20060714142738.265a7a98@localhost.localdomain>
	<44B80E51.7010901@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45768
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1945916AbWGNXee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 19:34:34 -0400
To: greearb@candelatech.com
In-Reply-To: <44B80E51.7010901@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 14 Jul 2006 14:36:17 -0700

> Stephen Hemminger wrote:
> > The inline function compare_ether_addr is faster than memcmp.
> > Also, don't need to drag in proc_fs.h, the only reference to proc_dir_entry
> > is a pointer so the declaration is needed here.
> 
> Looks fine to me.

To me too, applied, thanks a lot.
