From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next V1 00/10] Mellanox Ethernet driver updates
 2013-01-30
Date: Tue, 5 Feb 2013 20:08:19 +0000
Message-ID: <1360094899.2857.30.camel@bwh-desktop.uk.solarflarecom.com>
References: <1359623231-4491-1-git-send-email-amirv@mellanox.com>
	 <20130131.135158.206758800827480029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <amirv@mellanox.com>, <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42401 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204Ab3BEUIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 15:08:22 -0500
In-Reply-To: <20130131.135158.206758800827480029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-31 at 13:51 -0500, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu, 31 Jan 2013 11:07:01 +0200
> 
> > Hi Dave,
> > 
> > This series contains updates to mlx4 driver.
> > Majority of the patches are small bug fixes. Another patch is to expose through
> > debugfs some HW resources to be used by external tools.
> > 
> > Patches done against net-next commit 1b13c97: "net/vxlan: Add ethtool drvinfo"
> > 
> > Changes from V0:
> > - Removed patch "net/mlx4_en: Add debugfs support". Need to find a standard way
> >   to do it, and no need to delay the other patches.
> 
> All applied, thanks.

The first time this series was posted (this is actually v2) I raised an
issue with the changes to interpretation of the VLAN tag in ethtool RX
NFC commands: <http://article.gmane.org/gmane.linux.network/257392/>.
The semantics are now definitely inconsistent between sfc and mlx4_en.
I asked Alexander what ixgbe (first implementation) does with the upper
4 bits, with the aim that all three implementations should be
consistent, but I haven't had an answer to that yet.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
