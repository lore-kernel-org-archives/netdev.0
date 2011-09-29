From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-proc: expose the tos values in /proc/net/[tcp|udp]
Date: Thu, 29 Sep 2011 15:32:59 -0400 (EDT)
Message-ID: <20110929.153259.169108824599752228.davem@davemloft.net>
References: <1317324162-21621-1-git-send-email-muralira@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: muralira@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317324162-21621-1-git-send-email-muralira@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Muraliraja Muniraju <muralira@google.com>
Date: Thu, 29 Sep 2011 12:22:42 -0700

> From: Murali Raja <muralira@google.com>
> 
> This patch exports the tos values from the inet_sock struct
> for tcp and udp into the /proc/net/tcp or /proc/net/udp respectively.
> This will not pickup per packet tos changes but it will address most
> of the cases. This is mainly useful as it would decrease reliance on
> tcpdump and also people without root access will be able to read
> the values.
> 
> Signed-off-by: Murali Raja <muralira@google.com>

You cannot change the layout of these files, they are parsed by userland
problems and therefore have a fixed API.

Netlink based socket dumping provides a proper, backwards compatible,
way to extend what is reported, so please consider adding your changes
there.
