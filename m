From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Make /proc per net namespace objects belong to
 container
Date: Sun, 14 Aug 2016 21:09:34 -0700 (PDT)
Message-ID: <20160814.210934.1735618512090159873.davem@davemloft.net>
References: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dmitry.torokhov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Date: Wed, 10 Aug 2016 14:35:59 -0700

> Currently [almost] all /proc objects belong to the global root, even if
> data belongs to a given namespace within a container and (at least for
> sysctls) we work around permssions checks to allow container's root to
> access the data.
> 
> This series changes ownership of net namespace /proc objects
> (/proc/net/self/* and /proc/sys/net/*) to be container's root and not
> global root when there exists mapping for container's root in user
> namespace.
> 
> This helps when running Android CTS in a container, but I think it makes
> sense regardless.
> 
> Changes from V1:
> 
> - added fix for crash when !CONFIG_NET_NS (new patch #1)
> - addressed Eric'c comments for error handling style in patch #3 and
>   added his Ack
> - adjusted patch #2 to use the same style of erro handling
> - sent out as series instead of separate patches

Series applied to net-next, thanks.
