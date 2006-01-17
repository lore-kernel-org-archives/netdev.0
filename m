From: Kumar Gala <galak@kernel.crashing.org>
Subject: NIP6_FMT "breaks" ifconfig
Date: Tue, 17 Jan 2006 16:35:01 -0600
Message-ID: <26F1D638-7A96-48C6-9191-74363C497820@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v746.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML List <linux-kernel@vger.kernel.org>, joe@perches.com,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932446AbWAQWfJ@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of NIP6_FMT from kernel.h in net/ipv6/addrconf.c changes how / 
proc/net/if_inet6 format's IPv6 addresses and thus breaks ifconfig's  
ability to display IPv6 addresses.  I'm not sure if this is  
acceptable breakage of a userspace app or not.

- kumar
