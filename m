From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with 2.6.33-rc4-git2
Date: Mon, 18 Jan 2010 22:34:55 +0100
Message-ID: <201001182234.55113.rjw@sisk.pl>
References: <20100115091053.GA5477@mac.home> <201001180136.45823.rjw@sisk.pl> <20100118083757.GA2619@mac.home>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756105Ab0ARVeO@vger.kernel.org>
In-Reply-To: <20100118083757.GA2619@mac.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 18 January 2010, Tino Keitel wrote:
> Hi,
> 
> reverting this commit fixes WoL for me:
> 
> commit 166a0fd4c788ec7f10ca8194ec6d526afa12db75
> Author: stephen hemminger <shemminger@vyatta.com>
> Date:   Mon Dec 14 08:50:12 2009 +0000
> 
>     sky2: leave PCI config space writeable
>     
>     Since power management is done by PCI subsystem as well as driver,
>     don't toggle the bit that disables PCI register writes.
>     
>     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>     Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Hmm, this is kind of interesting.

Perhaps we clear the WoL setting somewhere we shouldn't, but the
"disable PCI register writes" bit prevents this from actually happening?

Rafael
