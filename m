From: "David S. Miller" <davem@redhat.com>
Subject: Re: [bonding][patch] Change locking scheme
Date: Thu, 03 Apr 2003 06:39:37 -0800 (PST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030403.063937.40841673.davem@redhat.com>
References: <Pine.LNX.4.44.0304031357180.317-100000@jrslxjul4.npdj.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	bonding-announce@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, jgarzik@pobox.com
Return-path: <linux-net-owner@vger.kernel.org>
To: shmulik.hen@intel.com
In-Reply-To: <Pine.LNX.4.44.0304031357180.317-100000@jrslxjul4.npdj.intel.com>
List-Id: netdev.vger.kernel.org

   From: shmulik.hen@intel.com
   Date: Thu, 3 Apr 2003 17:38:37 +0300 (IDT)

   This change is based on last week's discussion regarding the fact that
   holding a lock_irqsave doesn't prevent softirqs from running which can
   cause deadlocks in certain situations.

BTW, current 2.5.x kernels will now spit out debugging messages when
this locking rule is violated (ie. local_bh_enable() is called
with processor interrupts disabled).

