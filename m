From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for June 23 (net)
Date: Thu, 23 Jun 2011 09:14:29 -0700
Message-ID: <20110623091429.2d51b0f0.randy.dunlap@oracle.com>
References: <20110623155431.6bfe3b40.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110623155431.6bfe3b40.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Jun 2011 15:54:31 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20110622:
> 
> The powerpc allyesconfig (and probably others) is still broken because we
> now build the staging drivers and because of a commit in the net tree.
> The breakage in Linus' tree is fixed by one of Andrew's patches above.
> 
> The net tree gained 2 build failures that I have left (see above).


When CONFIG_INET is not enabled:

net/core/dev.c:2535: error: implicit declaration of function 'ip_is_fragment'


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
