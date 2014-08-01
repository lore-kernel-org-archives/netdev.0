From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from
 modules
Date: Fri, 1 Aug 2014 08:44:16 -0400
Message-ID: <20140801124416.GB1316@redhat.com>
References: <20140730123513.GB14804@redhat.com>
 <53D9E789.4070607@mellanox.com>
 <20140731130756.GE11063@redhat.com>
 <20140731.122244.665794236590108427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amirv@mellanox.com, andi@firstfloor.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754697AbaHAMol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 08:44:41 -0400
Content-Disposition: inline
In-Reply-To: <20140731.122244.665794236590108427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2014 at 12:22:44PM -0700, David Miller wrote:
> From: Vivek Goyal <vgoyal@redhat.com>
> Date: Thu, 31 Jul 2014 09:07:56 -0400
> 
> > If there are performance implications of low memory profile, then user
> > needs to live with it. Otherwise they should not use low_memory_env
> > boot option to begin with.
> 
> I personally think we should avoid changing scripts, by having a kdump
> kernel force this low_mem profile to be true.

If we go with current implementation, we don't have to change any of the
existing scripts.  Current implementation enforces low mem profile in
drivers for kdump kernel.

I am growing more skeptical of suggested low_mem_env boot option as there
will be contention that for different amount of low memory there should
be different profiles. One might argue that for 256MB use one kind of
profile while same profile might not be best fit for 2G of memory.

So instead of venturing into too generic option, I am fine with sticking
to a more custom option which works for kdump use case (is_kdump_kernel()).

So I would like to ack this patch series in current form.

Acked-by: Vivek Goyal <vgoyal@redhat.com>

Thanks
Vivek
