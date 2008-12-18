From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/2] move flow control definitions to mii.h
Date: Wed, 17 Dec 2008 16:17:08 -0800
Message-ID: <20081217161708.cb83783c.akpm@linux-foundation.org>
References: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
	<1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com,
	steve.glendinning@smsc.com
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43822 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751346AbYLRARN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 19:17:13 -0500
In-Reply-To: <1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Dec 2008 12:38:20 +0000
Steve Glendinning <steve.glendinning@smsc.com> wrote:

> flags used within drivers for indicating tx and rx flow control are
> defined in 4 drivers (and probably more), move these constants to mii.h.
> 
> The 3 SMSC drivers use the same constants (FLOW_CTRL_TX), but TG3 uses
> TG3_FLOW_CTRL_TX, so this patch also renames the constants within TG3.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> ---
>  drivers/net/smsc911x.h     |    3 --
>  drivers/net/smsc9420.h     |    3 --
>  drivers/net/tg3.c          |   50 ++++++++++++++++++++++----------------------
>  drivers/net/tg3.h          |    2 -
>  drivers/net/usb/smsc95xx.c |    2 -
>  include/linux/mii.h        |    4 +++

In file included from drivers/net/bnx2.c:52:
drivers/net/bnx2.h:6851:1: warning: "FLOW_CTRL_TX" redefined
In file included from drivers/net/bnx2.c:37:
include/linux/mii.h:139:1: warning: this is the location of the previous definition
In file included from drivers/net/bnx2.c:52:
drivers/net/bnx2.h:6852:1: warning: "FLOW_CTRL_RX" redefined

There are unfixed definitions of FLOW_CTRL_TX in drivers/net/bnx2.h and
drivers/net/bnx2x_link.h.
