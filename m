From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] qlge: Fix sparse endian warning for inbound packet
 control block flags.
Date: Mon, 05 Jan 2009 18:18:29 -0800 (PST)
Message-ID: <20090105.181829.241108247.davem@davemloft.net>
References: <20090105222600.GA4232@susedev.qlogic.org>
	<1231194452-10671-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47516
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751765AbZAFCS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 21:18:29 -0500
In-Reply-To: <1231194452-10671-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon,  5 Jan 2009 14:27:29 -0800

> Changed flags element from __le32 to 3 reserved bytes and one byte of
> flags.  Changed flags bit definitions to reflect byte width instead of
> __le32 width.
> 
> Warnings:
> drivers/net/qlge/qlge_main.c:1206:16: warning: restricted degrades to integer
> drivers/net/qlge/qlge_main.c:1207:16: warning: restricted degrades to integer
> drivers/net/qlge/qlge_main.c:1233:17: warning: restricted degrades to integer
> drivers/net/qlge/qlge_main.c:1276:17: warning: restricted degrades to integer
> drivers/net/qlge/qlge_main.c:1349:19: warning: restricted degrades to integer
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
