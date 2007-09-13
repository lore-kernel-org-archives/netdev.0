From: Roland Dreier <rdreier@cisco.com>
Subject: Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 14:00:43 -0700
Message-ID: <aday7fal1qc.fsf@cisco.com>
References: <OF79F6C618.02039854-ON87257355.00646A35-88257355.0064AB34@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761526AbXIMVBB@vger.kernel.org>
In-Reply-To: <OF79F6C618.02039854-ON87257355.00646A35-88257355.0064AB34@us.ibm.com> (Shirley Ma's message of "Thu, 13 Sep 2007 11:22:16 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 >         Since ehca can support 4K MTU, we would like to see a patch in 
 > IPoIB to allow link MTU to be up to 4K instead of current 2K for 2.6.24 
 > kernel. The idea is IPoIB link MTU will pick up a return value from SM's 
 > default broadcast MTU. This patch should be a small patch, I hope you are 
 > OK with this.

It's actually not small, since it turns the skb allocation into a
4100-byte buffer, which ends up being more than 1 page usually, which
means it fails if memory is fragmented.

Anyway given the backlog anything substantial that hasn't been posted
already is almost surely going to have to wait until 2.6.25.
