From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: driver: samsung: keep off in Kconfig by default
Date: Wed, 14 May 2014 15:05:40 -0400 (EDT)
Message-ID: <20140514.150540.789420080702346332.davem@davemloft.net>
References: <20140514182416.106B1904@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, joe@perches.com, bh74.an@samsung.com,
	netdev@vger.kernel.org
To: dave@sr71.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140514182416.106B1904@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Hansen <dave@sr71.net>
Date: Wed, 14 May 2014 11:24:16 -0700

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> These are a pet peeve of mine: Kconfig options that very few
> people need turned on, but that default to y.
> 
> I know that this doesn't generate any code by itself, but it
> does get in the way of every single person that does an
> oldconfig.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

The general policy we have is that VENDOR guards are on by default.
