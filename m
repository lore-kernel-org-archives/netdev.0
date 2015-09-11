From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix dependency on IPv6 defrag.
Date: Fri, 11 Sep 2015 15:39:19 -0700 (PDT)
Message-ID: <20150911.153919.659426861413559283.davem@davemloft.net>
References: <1442008876-19462-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442008876-19462-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Fri, 11 Sep 2015 15:01:16 -0700

> When NF_CONNTRACK is built-in, NF_DEFRAG_IPV6 is a module, and
> OPENVSWITCH is built-in, the following build error would occur:
> 
> net/built-in.o: In function `ovs_ct_execute':
> (.text+0x10f587): undefined reference to `nf_ct_frag6_gather'
> 
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied, thanks.
