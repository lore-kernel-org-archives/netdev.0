From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: tunnels - enable module autoloading
Date: Wed, 21 May 2014 15:47:44 -0400 (EDT)
Message-ID: <20140521.154744.124910385161203311.davem@davemloft.net>
References: <20140515.153721.2222505094570361361.davem@davemloft.net>
	<1400188890-2038-1-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	kuznet@ms2.inr.ac.ru
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400188890-2038-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Thu, 15 May 2014 23:21:30 +0200

> Enable the module alias hookup to allow tunnel modules to be autoloaded on demand.
> 
> This is in line with how most other netdev kinds work, and will allow userspace
> to create tunnels without having CAP_SYS_MODULE.
> 
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> ---
> v2: add ';'
> 
> Hi Dave,
> 
> I must have sent out the wrong version of this patch. Sorry for the inconvenience!

Applied to net-next, although I never saw a firm conclusion in the
thread for the original patch where there was a discussion about
whether this is already possible or not.
