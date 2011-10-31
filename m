From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding:update speed/duplex for NETDEV_CHANGE
Date: Mon, 31 Oct 2011 20:48:28 +0000
Message-ID: <1320094108.2735.15.camel@bwh-desktop>
References: <4EAE0D9A.9060408@gmail.com>
	 <e00468a2cbb8a25d7a89028e876769449454309f.1320070684.git.wpan@redhat.com>
	 <1320084906.2735.9.camel@bwh-desktop>  <14973.1320093129@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Weiping Pan <wpan@redhat.com>, <netdev@vger.kernel.org>,
	<andy@greyhouse.net>, <linux-kernel@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14973.1320093129@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-10-31 at 13:32 -0700, Jay Vosburgh wrote:
[...]
> 	This particular case arises only during enslavement.  The call
> to bond_update_speed_duplex call has failed, but the device is marked by
> bonding to be up.  Bonding complains that the device isn't down, but it
> cannot get speed and duplex, and therefore is assuming them to be
> 100/Full.
> 
> 	The catch is that this happens only for the ARP monitor, because
> it initially presumes a slave to be up regardless of actual carrier
> state (for historical reasons related to very old 10 or 10/100 drivers,
> prior to the introduction of netif_carrier_*).

Right, I gathered that.  Is there any reason to use the ARP monitor when
all slaves support link state notification?  Maybe the bonding
documentation should recommend miimon in section 7, not just in section
2.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
