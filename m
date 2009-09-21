From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/6] net: remove kfree_skb on a NULL pointer in
 af_netlink.c
Date: Mon, 21 Sep 2009 13:54:46 -0700 (PDT)
Message-ID: <20090921.135446.193691811.davem@davemloft.net>
References: <20090918005729.25594.14261.stgit@localhost.localdomain>
	<20090917.182445.240085155.davem@davemloft.net>
	<4AB76BD3.80802@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, linux-scsi@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4AB76BD3.80802@intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 21 Sep 2009 12:04:35 +0000

>>   
> OK, but this depends on the unlikely() macro in kfree_skb() to catch a
> case that is the expected non-error case. Would it be better to wrap
> the kfree_skb() in an if statement to avoid hitting the unlikely()
> macro?  Or is the performance hit from the unlikely() macro so small
> this is not an issue?  Thanks for looking at these.
> 

Expands too much code inline, that's why we don't do it that
way.
