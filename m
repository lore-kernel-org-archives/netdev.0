From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (0/9) free_netdev -- delay freeing of net_device structure
 till after last use
Date: Tue, 19 Aug 2003 16:24:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F42877B.9040407@pobox.com>
References: <20030819121800.009db89b.shemminger@osdl.org> <20030819124818.476dc36d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
   mochel@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819124818.476dc36d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David,

Considering that these patches introduce only a tiny diff in the 
low-level net driver, and that the viro work is still pending, I'm ok 
with going ahead and applying these patches.

Since they mix net/* and drivers/net/*, I would actually prefer that you 
merge 100% of the patchset, once the patchset is ok with you.

Also, my tendency is to apply patches 1-8, and not apply patch 9 just 
yet.  Even though patch 9 is a fix, those specific areas of code, I'm 
betting, will change when those drivers are fixed WRT full dynamic 
allocation and refcounting.

Comments?

	Jeff
