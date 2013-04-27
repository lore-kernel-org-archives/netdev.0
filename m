From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: restore source compatibility
Date: Fri, 26 Apr 2013 23:27:59 -0400 (EDT)
Message-ID: <20130426.232759.528213241802263204.davem@davemloft.net>
References: <877gk2r64z.wl%atzm@stratosphere.co.jp>
	<20130426165444.317d4aad@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: atzm@stratosphere.co.jp, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, dlstevens@us.ibm.com,
	mike.rapoport@ravellosystems.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460Ab3D0D2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 23:28:02 -0400
In-Reply-To: <20130426165444.317d4aad@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 26 Apr 2013 16:54:44 -0700

> The commit:
>     vxlan: Allow setting destination to unicast address.

Please reference commits both by SHA1 ID and the commit header line text,
in this format:

	commit ${SHA1_ID} ("Commit header line text.")

> Broke source compatibility with exported user headers.
> Compile fails with older iproute2 source fails since IFLA_VXLAN_REMOTE not defined.

Judging by your patch, the problem is that IFLA_VXLAN_GROUP is not defined,
not IFLA_VXLAN_REMOTE.

Are the semantic change issues here as well?  Just wondering.
