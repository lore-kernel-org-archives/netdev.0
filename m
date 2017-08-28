From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] NCSI VLAN Filtering Support
Date: Mon, 28 Aug 2017 16:50:01 -0700 (PDT)
Message-ID: <20170828.165001.1442421762159241248.davem@davemloft.net>
References: <20170828061843.24349-1-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        openbmc@lists.ozlabs.org, joel@jms.id.au, benh@kernel.crashing.org,
        gwshan@linux.vnet.ibm.com, ratagupt@in.ibm.com
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828061843.24349-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Mon, 28 Aug 2017 16:18:40 +1000

> This series (mainly patch 2) adds VLAN filtering to the NCSI implementation.
> A fair amount of code already exists in the NCSI stack for VLAN filtering but
> none of it is actually hooked up. This goes the final mile and fixes a few
> bugs in the existing code found along the way (patch 1).
> 
> Patch 3 adds the appropriate flag and callbacks to the ftgmac100 driver to
> enable filtering as it's a large consumer of NCSI (and what I've been
> testing on).
> 
> v3:	- Add comment describing change to ncsi_find_filter()
> 	- Catch NULL in clear_one_vid() from ncsi_get_filter()
> 	- Simplify state changes when kicking updated channel

Series applied.
