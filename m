From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET 0/18] FRTO: fixes and small changes + SACK enhanced
 version
Date: Thu, 22 Feb 2007 00:15:19 -0800 (PST)
Message-ID: <20070222.001519.66175915.davem@davemloft.net>
References: <11717439662097-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pasi.sarolahti@nokia.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751471AbXBVIPU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 03:15:20 -0500
In-Reply-To: <11717439662097-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Date: Sat, 17 Feb 2007 22:25:48 +0200

> Here is a set of patches that fixes most of the flaws the current FRT=
O
> implementation (specified in RFC4138) has, besides that, the last two
> patches add SACK-enhanced FRTO (not enabled unless frto sysctl is set
> to 2, which allows using of the basic version also with SACK). There
> are some depencies to the earlier patches in the set (hard to list
> all thoughts I've had, but not all combinations are not good ones
> even if they apply cleanly).

Thank you for this work.  I've applied all of your patches to
a tree I created for TCP development at:

	kernel.org:/pub/scm/linux/kernel/git/davem/tcp-2.6.git

If you have any further bug fixes or enhancements to FRTO we
can put it there too.

I intend to merge changes in the tcp-2.6 tree into 2.6.22 once
the merge window opens for that.
