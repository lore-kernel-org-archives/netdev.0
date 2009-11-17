From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 17 Nov 2009 01:00:46 -0800 (PST)
Message-ID: <20091117.010046.262845281.davem@davemloft.net>
References: <200911170830.nAH8Utli010605@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56168
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752901AbZKQJA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 04:00:29 -0500
In-Reply-To: <200911170830.nAH8Utli010605@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 17 Nov 2009 00:30:55 -0800

> +#include <bfa_timer.h>
> +#include <cs/bfa_debug.h>

More and more assumptions that the current directory is in
the header file search path.  Use "dir/file.h" instead please.
