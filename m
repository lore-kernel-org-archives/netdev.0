From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from modules
Date: Sun, 27 Jul 2014 17:48:32 -0700
Message-ID: <877g2y9ulb.fsf@tassilo.jf.intel.com>
References: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vivek Goyal <vgoyal@redhat.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58927 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbaG1Asd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jul 2014 20:48:33 -0400
In-Reply-To: <1406473156-4077-1-git-send-email-amirv@mellanox.com> (Amir
	Vadai's message of "Sun, 27 Jul 2014 17:59:13 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amir Vadai <amirv@mellanox.com> writes:

> Hi,
>
> I'm sending this patchset to net-next because it touches a commit [1] that was
> applied lately to net-next.

It would be better to have a generic function for "run with small
memory", that can be also triggered in other ways, e.g. a sysctl or
a boot opion, with kdump just another user.

There are low memory cases which are not kdump.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
