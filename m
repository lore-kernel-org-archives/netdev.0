From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in tun.c
Date: Tue, 25 Mar 2014 21:19:16 -0400 (EDT)
Message-ID: <20140325.211916.1629861072755372952.davem@davemloft.net>
References: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, xemul@parallels.com,
	wuzhy@linux.vnet.ibm.com, therbert@google.com, yamato@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: monamagarwal123@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Monam Agarwal <monamagarwal123@gmail.com>
Date: Mon, 24 Mar 2014 00:02:32 +0530

> This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
> 
> The rcu_assign_pointer() ensures that the initialization of a structure       
> is carried out before storing a pointer to that structure. 
> And in the case of the NULL pointer, there is no structure to initialize. 
> So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)
> 
> Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>

Applied.
