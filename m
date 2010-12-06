From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH 2/2] bluetooth: Use printf extension %pMbt
Date: Mon, 6 Dec 2010 16:15:07 -0200
Message-ID: <20101206181507.GC883@vigoh>
References: <cover.1291419007.git.joe@perches.com>
 <b966e9510dec12556a3d1313b026cb2c8281e4d6.1291419007.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61743 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960Ab0LFSOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 13:14:49 -0500
Content-Disposition: inline
In-Reply-To: <b966e9510dec12556a3d1313b026cb2c8281e4d6.1291419007.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

* Joe Perches <joe@perches.com> [2010-12-03 18:33:04 -0800]:

> Save some text and bss.
> Remove function batostr so there's no possibility of bad output.
> 
> from the net/bluetooth directory:
> 
> $ size built-in.o.*
>    text	   data	    bss	    dec	    hex	filename
>  293562	  16265	  70088	 379915	  5cc0b	built-in.o.allyesconfig.new
>  294619	  16269	  70480	 381368	  5d1b8	built-in.o.allyesconfig.old
>   30359	    772	     56	  31187	   79d3	built-in.o.btonly.new
>   30555	    776	     92	  31423	   7abf	built-in.o.btonly.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/bluetooth/bnep/core.c   |    3 +--
>  net/bluetooth/cmtp/core.c   |    2 +-
>  net/bluetooth/hci_conn.c    |    6 +++---
>  net/bluetooth/hci_core.c    |    8 ++++----
>  net/bluetooth/hci_event.c   |    6 +++---
>  net/bluetooth/hci_sysfs.c   |   10 +++++-----
>  net/bluetooth/hidp/core.c   |    4 ++--
>  net/bluetooth/l2cap.c       |   19 +++++++++----------
>  net/bluetooth/lib.c         |   14 --------------
>  net/bluetooth/rfcomm/core.c |   16 ++++++++--------
>  net/bluetooth/rfcomm/sock.c |    8 ++++----
>  net/bluetooth/rfcomm/tty.c  |    6 +++---
>  net/bluetooth/sco.c         |   12 ++++++------
>  13 files changed, 49 insertions(+), 65 deletions(-)

This patch doesn't apply to the bluetooth-next-2.6 tree. Can you please rebase
it against the bluetooth-next-2.6 tree? The tree is at:

git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth-next-2.6.git


-- 
Gustavo F. Padovan
http://profusion.mobi
