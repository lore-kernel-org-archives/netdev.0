From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.68] [BRIDGE] Use list_ macros for bridge port list.
Date: Thu, 24 Apr 2003 13:31:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030424.133154.98867715.davem@redhat.com>
References: <20030424135431.11cf3fe6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030424135431.11cf3fe6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 24 Apr 2003 13:54:31 -0700

   This replaces the singly linked list in net_bridge structure with the
   list_ macro's (doubly linked).   It makes deleting an interface easier
   since no lookup required; but the real motivation is to setup for the
   next step where bridge rwlock is replaced with spin_lock and RCU.

Maybe use list_for_each_entry where appropriate?  If those were
not used because *_rcu variants do not exist, just add the rcu
versions to linux/list.h

Thanks.
