From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] Fixed stacked vlan usage on top of bonds
Date: Fri, 16 May 2014 22:29:50 -0400 (EDT)
Message-ID: <20140516.222950.2105973332786166382.davem@davemloft.net>
References: <1400275239-15419-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com, kaber@trash.net,
	j.vosburgh@gmail.com, andy@greyhouse.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887AbaEQC3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 22:29:53 -0400
In-Reply-To: <1400275239-15419-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Fri, 16 May 2014 17:20:37 -0400

> Bonding device driver now support q-in-q on top for bonds.  There are
> a few issues here though.
> 
> First, when arp monitoring is used, bonding driver will not correctly
> tag traffic if the source of the arp device was configured on top of
> q-in-q.  It may also incorrectly pick the wrong vlan id if the ordering
> of that upper devices isn't as expected (there is no guarntee on ordering).
> 
> Second, the alb/tlb may use what would be considered 'inner' vlans in
> its learning announcements, as it simply announces all vlans configured
> on top of the bond without regard for encapsulation/stacking.
> 
> This series fixes the above 2 issues.  This series also depends on the
> functionality introduced in
> 	http://patchwork.ozlabs.org/patch/349766/
> 
> Since v1:
>   - Changed how patch1 verifies the device path.  We no longer use the
>     _all_upper version of the function.  We find the path and if it was
>     found, then collect the vlan information.
>   - Use the constant to devine maximum vlan nest level support on top
>     of bonding.  This can be changed if 2 is too low.
>   - Inlude patch2 into the series.

Series applied, thanks Vlad.
