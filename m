From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] (v2) arlan: remove gcc warning with CONFIG_PROC_FS=n
Date: Thu, 27 Jan 2005 08:47:05 -0800
Message-ID: <20050127164705.GC747@bougret.hpl.hp.com>
References: <41F7369E.8070704@osdl.org> <41F84605.5060501@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <41F84605.5060501@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 26, 2005 at 05:38:13PM -0800, Randy.Dunlap wrote:
> Here's an update (as pointed out off-list).
> Please replace the first one if that works for you.
> 
> 
> arlan: Fix gcc warning.
> 
> With CONFIG_PROC_FS=n, gcc complains:
> drivers/net/wireless/arlan-main.c:1858: warning: statement with no effect
> 
> Also remove a useless semi-colon on a #define.
> 
> Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
> 
> diffstat:=
>  drivers/net/wireless/arlan.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

	I've never touched that driver, but it looks ok to me. I hope
Jeff will pick it up.

	Jean
