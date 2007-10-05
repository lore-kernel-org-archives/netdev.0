From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 14:18:09 -0700 (PDT)
Message-ID: <20071005.141809.55498410.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<200710051846.19965.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: netdev@axxeo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38942
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751425AbXJEVSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 17:18:12 -0400
In-Reply-To: <200710051846.19965.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <netdev@axxeo.de>
Date: Fri, 5 Oct 2007 18:46:19 +0200

> Could this driver be split into more files. 8k lines per file
> is quite a lot. Although GCC might optimize it best this way :-)

Absolutely not!!!!!!!

I hate multiple file drivers, with a passion, they absolutely and
positivel suck.  I cringe every time I have to study a driver that
is broken up into multiple files.

They are a nightmare to hack on.  You have to keep typing in grep
commands, be a cscope wizard, or whatever to search around and find
the file in which the function or variable you want to learn about.

If it's all in one file, you can just sit in your single editor
buffer and get a lot of work done.

And to top it off such multi-file drivers tend to be a lot larger
and thus even harder to understand.

Multi-file drivers, just say no.
