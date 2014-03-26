From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 8/9] net: filter: rework/optimize internal
 BPF interpreter's instruction set
Date: Tue, 25 Mar 2014 20:17:12 -0400 (EDT)
Message-ID: <20140325.201712.1651156258234145348.davem@davemloft.net>
References: <1395749457-16178-1-git-send-email-dborkman@redhat.com>
	<1395749457-16178-9-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org, hagen@jauu.net,
	keescook@chromium.org, pmoore@redhat.com, mingo@kernel.org,
	hpa@linux.intel.com, linux-kernel@vger.kernel.org
To: dborkman@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395749457-16178-9-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 25 Mar 2014 13:10:56 +0100

>   - Conditional jt/jf targets replaced with jt/fall-through,
>     and forward/backward jumps now possible as well

Ummm... does anyone even remember why backwards jumps were not allowed
in the original BPF?

It's to guarentee forward progress in the filter.

Allowing branching backward would allow endless loops.

Please remove this feature.
