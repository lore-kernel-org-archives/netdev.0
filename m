From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] proc_fops: convert drivers/isdn/ to seq_file
Date: Sun, 03 Jan 2010 21:26:48 -0800 (PST)
Message-ID: <20100103.212648.225653590.davem@davemloft.net>
References: <200912220025.nBM0PVBC005140@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, adobriyan@gmail.com,
	tilman@imap.cc
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50299
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752951Ab0ADF0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:26:44 -0500
In-Reply-To: <200912220025.nBM0PVBC005140@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 21 Dec 2009 16:25:31 -0800

> From: Alexey Dobriyan <adobriyan@gmail.com>
> 
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
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: Tilman Schmidt <tilman@imap.cc>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Tilman has requested some fixes to the documentation text.
So I'm waiting for a fixed up version.
