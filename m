From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for September 13 (3c509)
Date: Sun, 14 Sep 2008 14:17:57 -0700
Message-ID: <20080914141757.899f71eb.randy.dunlap@oracle.com>
References: <20080913162344.ab395285.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080913162344.ab395285.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/3c509.c fails (CONFIG_PM=y) with:

drivers/built-in.o:(.data+0x7dcc): undefined reference to `el3_resume'
drivers/built-in.o:(.data+0x7e08): undefined reference to `el3_resume'

It seems that this function does not exist in the source file.

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
