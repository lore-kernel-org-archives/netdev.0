From: David Miller <davem@davemloft.net>
Subject: Re: [linux-stable] i40e: Don't stop driver probe when querying DCB
 config fails
Date: Wed, 13 Aug 2014 16:33:05 -0700 (PDT)
Message-ID: <20140813.163305.1708926944910132754.davem@davemloft.net>
References: <1407929455-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, neerav.parikh@intel.com,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	catherine.sullivan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1407929455-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 Aug 2014 04:30:55 -0700

> From: Neerav Parikh <neerav.parikh@intel.com>
> 
> Commit id: 014269ff376f552363ecdab78d3d947fbe2237d9 in Linus's tree
> should be queued up for stable 3.14 & 3.15 since the i40e driver will
> not load when DCB is enabled, unless this patch is applied.
> 
> In case of any AQ command to query port's DCB configuration fails
> during driver's probe time; the probe fails and returns an error.
> 
> This patch prevents this issue by continuing the driver probe even
> when an error is returned.
> 
> Also, added an error message to dump the AQ error status to show what
> error caused the failure to get the DCB configuration from firmware.
> 
> Change-ID: Ifd5663512588bca684069bb7d4fb586dd72221af
> Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Queued up for -stable, thanks.
