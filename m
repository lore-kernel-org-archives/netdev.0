From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: make mii_status sysfs node consistent
Date: Mon, 11 Jan 2016 17:16:19 -0500 (EST)
Message-ID: <20160111.171619.1907777399182966008.davem@davemloft.net>
References: <1452303336-28203-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452303336-28203-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Fri,  8 Jan 2016 20:35:36 -0500

> The spew in /proc/net/bonding/bond0 uses netif_carrier_ok() to determine
> mii_status, while /sys/class/net/bond0/bonding/mii_status looks at
> curr_active_slave, which doesn't actually seem to be set sometimes when
> the bond actually is up. A mode 4 bond configured via ifcfg-foo files on a
> Red Hat Enterprise Linux system, after boot, comes up clean and
> functional, but the sysfs node shows mii_status of down, while proc shows
> up. A simple enough fix here seems to be to use the same method for
> determining up or down in both places, and I'd opt for the one that seems
> to match reality.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Seems reasonable, applied, thanks.
