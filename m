From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netxen: avoid invalid iounmap
Date: Fri, 16 Jan 2009 11:03:47 -0800 (PST)
Message-ID: <20090116.110347.196376948.davem@davemloft.net>
References: <1232130484-25188-1-git-send-email-dhananjay@netxen.com>
	<1232130484-25188-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934530AbZAPTED@vger.kernel.org>
In-Reply-To: <1232130484-25188-2-git-send-email-dhananjay@netxen.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Fri, 16 Jan 2009 10:28:03 -0800

> For NX3031 only one I/O range is mapped, so unmapping other
> two which are used by older chips, causes this warning on
> ppc64.
> 
> "Attempt to iounmap early bolted mapping at 0x0000000000000000"
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
