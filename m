From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from
 modules
Date: Mon, 28 Jul 2014 08:26:09 -0400
Message-ID: <20140728122609.GB32337@redhat.com>
References: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
 <877g2y9ulb.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbaG1M06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 08:26:58 -0400
Content-Disposition: inline
In-Reply-To: <877g2y9ulb.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 27, 2014 at 05:48:32PM -0700, Andi Kleen wrote:
> Amir Vadai <amirv@mellanox.com> writes:
> 
> > Hi,
> >
> > I'm sending this patchset to net-next because it touches a commit [1] that was
> > applied lately to net-next.
> 
> It would be better to have a generic function for "run with small
> memory", that can be also triggered in other ways, e.g. a sysctl or
> a boot opion, with kdump just another user.
> 
> There are low memory cases which are not kdump.

I am fine with a boot option to suggest low memory profile and kdump
scripts can be modified to automatically append that command line option
to second kernel.

Thanks
Vivek
