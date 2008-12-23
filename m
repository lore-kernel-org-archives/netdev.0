From: David Miller <davem@davemloft.net>
Subject: Re: test message
Date: Tue, 23 Dec 2008 14:49:23 -0800 (PST)
Message-ID: <20081223.144923.157458777.davem@davemloft.net>
References: <20081223223818.GC32049@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751487AbYLWWtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:49:21 -0500
In-Reply-To: <20081223223818.GC32049@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Tue, 23 Dec 2008 14:38:18 -0800

> Having some trouble with git-send-email.  This is a test from mutt.

The biggest problem with git-send-email is that for
a long time it emitted illegal SMTP headers which
we block at vger.kernel.org

When a user's name appears in SMTP headers, such as
the To: and CC: fields, and that user's name has
a "." or similar character in it, it must be completely
surrounded by double quotes.

So this is what you might be running into, although
this should have been fixed in GIT some time ago.
