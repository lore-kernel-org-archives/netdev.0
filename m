From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.0-test3-bk8][ATM] fix ambassador.c
Date: Thu, 21 Aug 2003 19:31:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030821193149.A18920@electric-eye.fr.zoreil.com>
References: <1061478906.1069.23.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.com,
   Kernel List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Content-Disposition: inline
In-Reply-To: <1061478906.1069.23.camel@lima.royalchallenge.com>; from vinay-rc@naturesoft.net on Thu, Aug 21, 2003 at 08:45:05PM +0530
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vinay K Nallamothu <vinay-rc@naturesoft.net> :
[...]
> drivers/atm/ambassador.c: 
> This patch cleans up sti/cli usage as well as minor timer cleanups.
[...]

The "dont_panic" function which uses cli/sti is only called from code
belonging to a "#if 0" section since revision 1.1 according to bk.

Remove it, everybody should feel better.

--
Ueimor
