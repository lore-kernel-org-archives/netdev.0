From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 12/24] net, diet: Make rtnetlink optional
Date: Tue, 6 May 2014 05:11:27 +0200
Message-ID: <20140506031127.GM2382@two.firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <1399328773-6531-13-git-send-email-andi@firstfloor.org>
 <20140505.230830.1291070654883866275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140505.230830.1291070654883866275.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The moment one of these "small" systems, or whatever you want to call
> it, tries to use any feature added to device configuration in the last
> 20 years ioctl doesn't cut it.

They will simply not use all that complexity ever, 400k is simply prohibitive
with 2MB.

If you want to keep netlink what would you remove instead?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
