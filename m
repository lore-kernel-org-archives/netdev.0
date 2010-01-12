From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/8] qlge: Add firmware coredump functionality.
Date: Mon, 11 Jan 2010 22:22:02 -0800 (PST)
Message-ID: <20100111.222202.66778648.davem@davemloft.net>
References: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48087
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750917Ab0ALGVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 01:21:53 -0500
In-Reply-To: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 11 Jan 2010 17:12:57 -0800

> Dump all regsiters and on chip RAM when a fatal firmware error is
> encountered.  This features is turn on by default but can be
> turned off with a module parameter.

There is no way you should crap into someone's kernel log
with a large amount of information by default.

Yes, this is true even on fatal errors.

If you can't dump the information in say a dozen lines, it
is more trouble than it's worth as a default.

Make the default to off.  Users can be asked to turn it on
if you need to capture more information for diagnostics,
and you personally can turn it on by default when doing
development.

Thanks.
