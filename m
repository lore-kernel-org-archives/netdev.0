From: "David S. Miller" <davem@davemloft.net>
Subject: Re: NIP6_FMT "breaks" ifconfig
Date: Tue, 17 Jan 2006 15:05:28 -0800 (PST)
Message-ID: <20060117.150528.108145661.davem@davemloft.net>
References: <26F1D638-7A96-48C6-9191-74363C497820@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964877AbWAQXFq@vger.kernel.org>
To: galak@kernel.crashing.org
In-Reply-To: <26F1D638-7A96-48C6-9191-74363C497820@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kumar Gala <galak@kernel.crashing.org>
Date: Tue, 17 Jan 2006 16:35:01 -0600

> The use of NIP6_FMT from kernel.h in net/ipv6/addrconf.c changes how / 
> proc/net/if_inet6 format's IPv6 addresses and thus breaks ifconfig's  
> ability to display IPv6 addresses.  I'm not sure if this is  
> acceptable breakage of a userspace app or not.

I know, I have a fix from Yoshifuji in my tree and I'll
make sure Linus gets it.
