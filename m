From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix IPv6 exthdr handling with ct
 helpers.
Date: Thu, 17 Sep 2015 15:32:08 -0700 (PDT)
Message-ID: <20150917.153208.217018898295996196.davem@davemloft.net>
References: <1442254490-20385-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, dan.carpenter@oracle.com
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442254490-20385-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Mon, 14 Sep 2015 11:14:50 -0700

> Static code analysis reveals the following bug:
> 
>         net/openvswitch/conntrack.c:281 ovs_ct_helper()
>         warn: unsigned 'protoff' is never less than zero.
> 
> This signedness bug breaks error handling for IPv6 extension headers when
> using conntrack helpers. Fix the error by using a local signed variable.
> 
> Fixes:  cae3a2627520: "openvswitch: Allow attaching helpers to ct
> action"
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied, thanks.
