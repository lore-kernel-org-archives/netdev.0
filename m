From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 2/2] iproute: Add route showdump command (v2)
Date: Fri, 27 Jul 2012 09:03:22 +0400
Message-ID: <5012211A.4040307@parallels.com>
References: <50121F4D.8090606@parallels.com> <50121FB0.6060200@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:41943 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab2G0FD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 01:03:27 -0400
In-Reply-To: <50121FB0.6060200@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen, I have a question regarding the save and restore in iproute tool.

As you know, the save/restore pair for routes works in a very simple and
elegant manner -- on save the raw kernel rtnl stream is just put into a
file, on restore the _very_ _same_ messages are pushed back to the kernel.

Is the same trick possible to save and restore the addresses (the ip
addr command) as well? Or the RTM_GETADDR messages cannot be just read
from and written back to the network stack in a generic case?

Thanks,
Pavel
