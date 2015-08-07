From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: netcp: fix unused interface rx buffer size
 configuration
Date: Fri, 07 Aug 2015 00:02:45 -0700 (PDT)
Message-ID: <20150807.000245.1505694529225205290.davem@davemloft.net>
References: <1438721813-14044-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m-karicheri2@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: w-kwok2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438721813-14044-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>
Date: Tue, 4 Aug 2015 16:56:53 -0400

> Prior to this patch, rx buffer size for each rx queue
> of an interface is configurable through dts bindings.
> But for an interface, the first rx queue's rx buffer
> size is always the usual MTU size (plus usual overhead)
> and page size for the remaining rx queues (if they are
> enabled by specifying a non-zero rx queue depth dts
> binding of the corresponding interface).  This patch
> removes the rx buffer size configuration capability.
> 
> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>

Applied.
