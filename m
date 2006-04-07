From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch] ipv4: initialize arp_tbl rw lock
Date: Fri, 07 Apr 2006 13:14:45 -0700 (PDT)
Message-ID: <20060407.131445.02462792.davem@davemloft.net>
References: <20060407081533.GC11353@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fpavlic@de.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964883AbWDGUOx@vger.kernel.org>
To: heiko.carstens@de.ibm.com
In-Reply-To: <20060407081533.GC11353@osiris.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Fri, 7 Apr 2006 10:15:33 +0200

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> The qeth driver makes use of the arp_tbl rw lock. CONFIG_DEBUG_SPINLOCK
> detects that this lock is not initialized as it is supposed to be.
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

As Stephen Hemminger pointed out this change is bogus, the
lock is initialized at run time by the ARP layer.
