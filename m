From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/2] L2TP:Adjust intf MTU, add underlay L3,
 L2 hdrs.
Date: Thu, 06 Apr 2017 13:43:49 -0700 (PDT)
Message-ID: <20170406.134349.901826134748051625.davem@davemloft.net>
References: <alpine.DEB.2.11.1704051701220.19131@vera98.eng.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, kleptog@svana.org,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org
To: parameswaran.r7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1704051701220.19131@vera98.eng.brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Date: Wed, 5 Apr 2017 17:05:49 -0700 (PDT)

> 
> Existing L2TP kernel code does not derive the optimal MTU for Ethernet
> pseudowires and instead leaves this to a userspace L2TP daemon or
> operator. If an MTU is not specified, the existing kernel code chooses
> an MTU that does not take account of all tunnel header overheads, which
> can lead to unwanted IP fragmentation. When L2TP is used without a
> control plane (userspace daemon), we would prefer that the kernel does a
> better job of choosing a default pseudowire MTU, taking account of all
> tunnel header overheads, including IP header options, if any. This patch
> addresses this.
> 
> Change-set is organized as a two part patch series, with one patch
> introducing a new kernel function to compute the IP overhead on a
> socket, and the other patch using this new kernel function to compute
> the default L2TP MTU for an Ethernet pseudowire.
> 
> Existing code also seems to assume an Ethernet (non-jumbo) underlay. The
> change proposed here uses the PMTU mechanism and the dst entry in the
> L2TP tunnel socket to directly pull up the underlay MTU (as the baseline
> number on top of which the encapsulation headers are factored in).
> An default MTU value of 1500 bytes is assumed as a fallback only if
> this fails. 
> 
> Fixed the kbuild test robot error in the previous posting.

Series applied, thanks.
