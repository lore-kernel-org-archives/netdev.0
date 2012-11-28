From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] arping: Fix finding of a default interface when no
 -I is specified.
Date: Thu, 29 Nov 2012 03:38:29 +0900
Message-ID: <50B65A25.1050501@linux-ipv6.org>
References: <1354018775-4966-1-git-send-email-jsynacek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jan Synacek <jsynacek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56345 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751236Ab2K1Sia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 13:38:30 -0500
In-Reply-To: <1354018775-4966-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Synacek wrote:
> By default, no interface string should be supplied. This ensures that we can
> recognize if an interface was specified or omitted. Previously, when -I was not
> used, default interface string was compiled-in and the automatic selection
> didn't work correctly.

Okay, but to retain default device support compiled in,
different patch applied.

Thank you, anyway.

P.S. Even if default interface compiled in, you can say "-I ''" to
override that.

--yoshfuji
