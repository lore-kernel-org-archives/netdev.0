From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.68+] [BRIDGE] Inline and _rcu change.
Date: Tue, 29 Apr 2003 01:30:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429.013043.98882273.davem@redhat.com>
References: <20030428134639.0011347c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030428134639.0011347c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 28 Apr 2003 13:46:39 -0700

   Two small changes:
   * Need _rcu on the list_for_each_entry in br_get_port because called in
     read path for some ioctl's
   * Move two small functions is_root_bridge and is_designated_port into
     inline's because they are so short.
   
Applied, thanks.
