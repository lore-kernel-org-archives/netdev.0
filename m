From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers: net: ethernet: intel: e1000: e1000_ethtool.c
 coding style fixes
Date: Mon, 18 Aug 2014 08:31:54 -0700
Message-ID: <1408375914.2741.1.camel@joe-AO725>
References: <1408180328-4827-1-git-send-email-cristos@vipserv.org>
	 <1408214489.2683.87.camel@joe-AO725> <53F21BEC.2070204@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53F21BEC.2070204@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-08-18 at 08:29 -0700, Alexander Duyck wrote:
> Doing any kind of pointer math on a void pointer is generally unsafe as
> it is an incomplete type.  The only reason why it works in GCC is
> because GCC has a nonstandard extension that makes it report as having a
> size of 1.

I know.  It's used in quite a few places in kernel code
so I believe it's now a base assumption for the kernel.
