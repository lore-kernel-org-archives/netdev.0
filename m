From: David Miller <davem@davemloft.net>
Subject: Re: bayom_epp patch
Date: Fri, 16 Dec 2011 15:53:56 -0500 (EST)
Message-ID: <20111216.155356.486973748890384985.davem@davemloft.net>
References: <1323777960.12740.2.camel@xbox360.hq.axsem.com>
	<4EE748BA.5080807@suse.cz>
	<1323815399.2558.2.camel@unreal.home.sailer.dynip.lugs.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: t.sailer@alumni.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760779Ab1LPUyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:54:45 -0500
In-Reply-To: <1323815399.2558.2.camel@unreal.home.sailer.dynip.lugs.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Sailer <t.sailer@alumni.ethz.ch>
Date: Tue, 13 Dec 2011 23:29:59 +0100

> Whitespace has been fixed.

Your email client corrupted the patch, breaking up long lines etc.
Email this thing to yourself and try to apply it, and do not resubmit
this until it works for you.

It is also not properly formed, you are putting the commit header line
for the patch in the email body, it belongs in the Subject.

You should go:

--------------------
Subject: [PATCH] baycom_epp: Improve parport handling, fix multi-core support

Parallel port settings no longer require an IO address value,
because addresses are automatically assigned by the PCI BIOS
 ...
Signed-off-by: Thomas Sailer <sailer@ife.ee.ethz.ch>
Signed-off-by: Steffen Koehler <steffen.koehler@tu-dresden.de>
--------------------
