From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] fix #51791 - bug? mac 00:00:00:00:00:00 with
 natsemi DP83815 after driver load
Date: Wed, 19 Nov 2014 15:35:28 -0500 (EST)
Message-ID: <20141119.153528.1764287151701305293.davem@davemloft.net>
References: <trinity-a7b6eb2e-598a-4ad0-9df5-7567cb544671-1416347483688@3capp-webde-bs54>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: devzero@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096AbaKSUfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 15:35:31 -0500
In-Reply-To: <trinity-a7b6eb2e-598a-4ad0-9df5-7567cb544671-1416347483688@3capp-webde-bs54>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Roland Kletzing" <devzero@web.de>
Date: Tue, 18 Nov 2014 22:51:23 +0100

> This one should fix Bugzilla #51791 

I'm sorry for being a pain, but I want to teach you how to properly
submit clean patches so that I don't need to go back and forth with
you in the future about these issues.

Your subject line needs adjusting.

After the [PATCH ...], there should be a properly subsystem prefix
followed by a colon character, which in this case could be "natsemi: "

Then, your subject line should be succinct and contain all of the
context necessary to understand exactly what the bug is about.

This means that the bug ID number doesn't belong there.  It's
completely ambiguous as to what bug repository that ID is for,
and such information belongs in the commit message body.

So when you mention bug IDs in the commit message body, say where
it's from.  If it's the main kernel bugzilla, say so.

Thanks.
