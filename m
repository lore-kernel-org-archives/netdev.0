From: "David S. Miller" <davem@davemloft.net>
Subject: Re: net 2.6.16-rc1: multiple ipv6 failures
Date: Tue, 17 Jan 2006 21:47:50 -0800 (PST)
Message-ID: <20060117.214750.37718950.davem@davemloft.net>
References: <43CDAA58.5000904@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751340AbWARFvf@vger.kernel.org>
To: jgarzik@pobox.com
In-Reply-To: <43CDAA58.5000904@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 17 Jan 2006 21:39:20 -0500

> 2) bind fails (which everyone on my network immediately noticed, and
> complained about).
> 
> > Jan 17 21:29:04 pretzel named[5110]: loading configuration from '/etc/named.conf'
> > Jan 17 21:29:04 pretzel named[5110]: /proc/net/if_inet6:sscanf() -> 1 (expected 6)
> > Jan 17 21:29:04 pretzel named[5110]: interfacemgr.c:827: unexpected error:
> > Jan 17 21:29:04 pretzel named[5110]: interface iteration failed: failure
> > Jan 17 21:29:04 pretzel named[5110]: not listening on any interfaces
> > Jan 17 21:29:04 pretzel named[5110]: command channel listening on 127.0.0.1#953
> > Jan 17 21:29:04 pretzel named[5110]: /proc/net/if_inet6:sscanf() -> 1 (expected 6)
> > Jan 17 21:29:04 pretzel named[5110]: interfacemgr.c:827: unexpected error:
> > Jan 17 21:29:04 pretzel named[5110]: interface iteration failed: failure

Known problem, fixed by Yoshifuji in current GIT.  /proc/net/if_net6's
output format got mistakedly changed, and this confused named and
ifconfig, among other things.
