From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/3] Make is_kdump_kernel() accessible from
 modules
Date: Mon, 25 Aug 2014 15:42:43 -0700 (PDT)
Message-ID: <20140825.154243.238344646519450592.davem@davemloft.net>
References: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, vgoyal@redhat.com,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbaHYWmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:42:44 -0400
In-Reply-To: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 25 Aug 2014 16:06:51 +0300

> I'm re-spinning this patchset. At the begining it was suggested to use a
> different name for the parameter, but at the end [3] the resolution was to
> leave it as it is in this patch.
> 
> Drivers need to know if running from kdump kernel in order to change their
> memory profile - since kdump environment is limited by available memory.
> Currently there are drivers that are using reset_devices as suggested in [2].
> In [2] it was suggested to use reset_devices, but the context was, to enable
> driver to know when the hardware device is needed to be reset, and not if this
> is a kdump environment. We think that is_kdump_kernel() is better suited to
> select between different memory profiles.
> 
> The first patch in this patchset exports a needed symbol in order to make
> is_kdump_kernel() accessible from the drivers. The rest of the patches change
> from reset_devices to is_kdump_kernel() in 2 networking drivers.
> 
> The idea of this patchset was suggested by Vivek Goyal.
> 
> Tested (only build) and applied on top of commit 8fc54f6: ("net: use
> reciprocal_scale() helper")
> 
> [1] - ea1c1af: ("net/mlx4_en: Reduce memory consumption on kdump kernel")
> [2] - https://lkml.org/lkml/2011/1/27/341
> [3] - http://www.spinics.net/lists/netdev/msg291492.html

Series applied, thanks Amir.
