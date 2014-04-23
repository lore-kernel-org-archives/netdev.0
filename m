From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy: micrel: fix bugged test on device tree
 loading for ksz9021
Date: Wed, 23 Apr 2014 14:59:26 -0400 (EDT)
Message-ID: <20140423.145926.998744821096383568.davem@davemloft.net>
References: <1398171664-32662-1-git-send-email-hchaumette@adeneo-embedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: hchaumette@adeneo-embedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398171664-32662-1-git-send-email-hchaumette@adeneo-embedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Date: Tue, 22 Apr 2014 15:01:04 +0200

> In ksz9021_load_values_from_of() val2 to val4 aren't tested against their
> initialization value.
> This causes the test to always succeed, and this value to be used as if it
> was loaded from the devicetree instead of being ignored, in case of a
> missing/invalid property in the ethernet OF device node.
> As a result, the value "0" is written to the relevant registers.
> 
> Change the conditions to test against the right initialization value.
> 
> Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>

Applied, thanks.
