From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net, thunderx: Use bool in structs where possible
Date: Thu, 18 Feb 2016 11:05:14 -0500 (EST)
Message-ID: <20160218.110514.652169911099659792.davem@davemloft.net>
References: <1455799149-19590-1-git-send-email-rrichter@caviumnetworks.com>
	<1455799149-19590-3-git-send-email-rrichter@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	rrichter@cavium.com
To: rrichter@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455799149-19590-3-git-send-email-rrichter@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <rrichter@caviumnetworks.com>
Date: Thu, 18 Feb 2016 13:39:09 +0100

> From: Robert Richter <rrichter@cavium.com>
> 
> Looks like the :1 notation was accidentally introduced (this still
> uses 1 byte per flag). Using bool instead, which is the common use.
> 
> Signed-off-by: Robert Richter <rrichter@cavium.com>

Such cleanups are not appropriate for 'net'.  Only real bug fixes should
be targetted that.

Respin these patches targetting the correct tree(s).
