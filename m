From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] proc_fops: convert drivers/isdn/ to seq_file
Date: Thu, 14 Jan 2010 03:11:14 -0800 (PST)
Message-ID: <20100114.031114.257830077.davem@davemloft.net>
References: <1263467281.28429@pingi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tilman@imap.cc, adobriyan@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756403Ab0ANLLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 06:11:05 -0500
In-Reply-To: <1263467281.28429@pingi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <keil@b1-systems.de>
Date: Thu, 14 Jan 2010 11:27:45 +0100

> Convert code away from ->read_proc/->write_proc interfaces.  Switch to
> proc_create()/proc_create_data() which make addition of proc entries
> reliable wrt NULL ->proc_fops, NULL ->data and so on.
> 
> Problem with ->read_proc et al is described here commit
> 786d7e1612f0b0adb6046f19b906609e4fe8b1ba "Fix rmmod/read/write races in
> /proc entries"
> 
> [akpm@linux-foundation.org: CONFIG_PROC_FS=n build fix]
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> Signed-off-by: Karsten Keil <keil@b1-systems.de>

Applied.
